require 'gitmirror'
require 'swift'
require 'active_support/number_helper/number_to_human_size_converter'

class ChefAutomationJob < ActiveJob::Base

  include MonsoonOpenstackAuthWrapper
  include POSIX::Spawn
  include ArcClient

  rescue_from(StandardError) do |exception|
    bt = Rails.backtrace_cleaner.clean(exception.backtrace)
    msg = "#{exception.message}:\n" + bt.join("\n")
    logger.error msg 
    @run.log msg 
    @run.update!(state: 'failed')
  end

  def perform(token, chef_automation, selector)

    Rails.logger.info "Running #{self.class.to_s} for automation(id=#{chef_automation.id})" 
    @run = Run.find_by_job_id!(job_id)

    @run.log "Selecting nodes with selector #{selector}\n"
    selected_agents = list_agents(selector)
    raise "No nodes selected by filter" if selected_agents.empty?
    @run.log "Selected nodes:\n" + 
             selected_agents.map {|a| "#{a.agent_id} #{a.facts["hostname"]}"}.join("\n") + 
             "\n"

    offline_agents = selected_agents.find_all { |a|!a.facts["online"] }
    if offline_agents.present?
      @run.log "The following nodes are not online:\n" + 
               offline_agents.map {|a| "#{a.agent_id} #{a.facts["hostname"]}"}.join("\n") +
               "\n"
      raise "Agent(s) are unavailable"
    end

    ensure_chef_enabled(token, selected_agents, chef_automation.chef_version)
     
    #create or update local mirror of repository
    repo = Gitmirror::Repository.new(chef_automation.repository)
    repo_path = repo.mirror()
    #TODO better error message when revision is not present
    sha = execute("git --git-dir=#{repo_path} rev-parse #{chef_automation.repository_revision}").strip
    @run.update_attribute(:repository_revision, sha)

    #TODO: use advisory locks and cache based on sha hash
    url = create_artifacts repo, sha

    jobs = schedule_jobs(selected_agents, chef_automation, url)
    @run.log("Scheduled #{jobs.length} #{'job'.pluralize(jobs.length)}:\n" + jobs.join("\n"))
    @run.update!(jobs: jobs, state: 'executing')
    #Schedule a lightweight job to track the job
    TrackAutomationJob.perform_later(token, @run.job_id)

  end 

  private

  def artifact_key(sha)
    "#{sha}-chef" 
  end

  def create_artifacts(repo, sha)
    Dir.mktmpdir do |dir|
      checkout_dir = ::File.join dir, "repo"
      tarball = ::File.join(dir, "#{artifact_key(sha)}.tgz")
      repo.checkout(checkout_dir, sha)
      if File.exists?(::File.join(checkout_dir, 'Berksfile'))
        @run.log("Berksfile detected. Running berks package...\n")
        #do a berks package
        Bundler.with_clean_env do
          Dir.chdir checkout_dir do
            execute "berks package #{tarball}" 
          end
        end
      else
        @run.log("Creating tarball of repository content...\n")
        #TODO: check for correct folder structure
        #tar the checkout dir
        execute "tar -c -z -C #{checkout_dir} -f #{tarball} ."
      end
      publish_tarball(tarball)
    end
  end


  def ensure_chef_enabled token, agents, chef_version
    jids = agents.find_all {|a| a.facts["agents"]["chef"] == "disabled" }.map do | agent |
      #TODO: handle individual errors 
      jid = arc.execute_job!(token, {
        to: agent.agent_id,
        timeout: 600,
        agent: 'chef',
        action: 'enable',
        payload: {chef_version: chef_version}.to_json
      })
      @run.log "Enabling chef on node #{agent.agent_id}/#{agent.facts["hostname"]} (job: #{jid})"
      jid
    end
    failed = false
    # TODO: Add timeout
    loop do
      jids.delete_if do |jid|
        job = arc.find_job!(token, jid)
        if job.status == "failed"
          @run.log "Job #{jid} failed"
          failed = true
        end
        %w{completed complete failed}.include? job.status
      end
      break if jids.empty?
      sleep 5
    end
      
  end

  def schedule_jobs(agents, automation, recipe_url)
    chef_payload = {
      run_list: automation.run_list,
      recipe_url: recipe_url,
      attributes: automation.chef_attributes,
      debug: false,
    }
    agents.map do |agent|
      #TODO: handle individual errors
      arc.execute_job!(current_user.token, {
        to: agent.agent_id,
        timeout: automation.timeout,
        agent: 'chef',
        action: 'zero',
        payload: chef_payload.to_json
      })
    end
  end

  def list_agents(filter)
    page = 1 
    agents = []
    loop do
      resp = arc.list_agents!(current_user.token, filter, %w{online hostname agents}, page, 100)
      agents.concat(resp.data)
      break if page >= resp.pagination.total_pages
      page += 1
    end
    return agents
  end


  def execute(command)
    out = `#{command} 2>&1` 
    raise "Executing [#{command}] failed (#{$?.exitstatus}):\n#{out}" if $?.exitstatus != 0
    out
  end

  def tarball_published?(sha)
    Swift.client.head_object(artifact_key(sha), "monsoon-automation")
    return true
  rescue SwiftClient::ResponseError
    return false
  end

  def publish_tarball(path)
    objectname = File.basename(path)
    human_size = ActiveSupport::NumberHelper::NumberToHumanSizeConverter.new(File.size?(path),{}).convert rescue ""
    @run.log("Uploading #{objectname} (#{human_size})...\n")
    File.open(path, "r") do |f|
      Swift.client.put_object objectname, f, "monsoon-automation", {"Content-Type" => 'application/gzip'}
      Swift.client.temp_url objectname, "monsoon-automation"
    end
  end
end
