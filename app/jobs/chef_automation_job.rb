require 'gitmirror'
require 'swift'
require 'ruby-arc-client'
require 'active_job/monsoon_openstack_auth'
class ChefAutomationJob < ActiveJob::Base

  include ActiveJob::MonsoonOpenstackAuth
  include POSIX::Spawn


  #TODO: This is crap, we need a better way to create a run and the correponding job
  before_enqueue do |job|
    token, owner, automation, selector = job.arguments
    Run.create!(job_id: job.job_id, automation_id: automation.id, owner: owner, selector: selector, project_id: automation.project_id, automation_attributes: automation.attributes)
  end

  rescue_from(StandardError) do |exception|
    @run.log exception.message + ":\n" + exception.backtrace.join("\n")
    @run.update(state: 'failed')
  end

  #TODO: remove owner argument (only needed for persiting the run entry atm  )
  def perform(token, owner, chef_automation, selector)

    Rails.logger.info "Running #{self.class.to_s} for automation(id=#{chef_automation.id})" 
    @run = Run.find_by_job_id!(job_id)

    @run.log "Selecting nodes with selector #{selector}"
    selected_agents = list_agents(selector)
    raise "No nodes selected by filter" if selected_agents.empty?
    @run.log "Selected nodes:" + selected_agents.map {|a| "#{a.agent_id} #{a.facts["hostname"]}"}.join("\n")

    offline_agents = selected_agents.find_all { |a|!a.facts["online"] }
    if offline_agents.present?
      @run.log "The following nodes are not online:\n" + offline_agents.map {|a| "#{a.agent_id} #{a.facts["hostname"]}"}.join("\n")
      raise "Agent(s) are unavailable"
    end

    ensure_chef_enabled(selected_agents, chef_automation.chef_version)
     
    #create or update local mirror of repository
    repo = Gitmirror::Repository.new(chef_automation.repository)
    repo_path = repo.mirror()
    #TODO better error message when revision is not present
    sha = execute("git --git-dir=#{repo_path} rev-parse #{chef_automation.repository_revision}").strip
    @run.update_attribute(:repository_revision, sha)

    #TODO: use advisory locks and cache based on sha hash
    url = Dir.mktmpdir do |dir|
      checkout_dir = ::File.join(dir, "repo")
      tarball = ::File.join(dir, "#{sha}.tgz")
      repo.checkout(checkout_dir, chef_automation.repository_revision)
      if File.exists?(::File.join(checkout_dir, 'Berksfile'))
        #do a berks package
        Bundler.with_clean_env do
          Dir.chdir checkout_dir do
            execute "berks package #{tarball}" 
          end
        end
      else
        #TODO: check for correct folder structure
        #tar the checkout dir
        execute "tar -c -z -C #{dir} -f #{tarball} ."
      end
      publish_tarball(tarball)
    end

    jobs = schedule_jobs(selected_agents, chef_automation, url)
    @run.update(jobs: jobs, state: 'executing')

  end 

  private

  def arc
    @arc ||= RubyArcClient::Client.new(current_user.service_url(:arc))
  end

  def ensure_chef_enabled agents, chef_version
    jids = agents.find_all {|a| a.facts["agents"]["chef"] == "disabled" }.map do | agent |
      #TODO: handle individual errors 
      jid = arc.execute_job!(current_user.token, {
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
    loop do
      jids.delete_if do |jid|
        job = arc.get_job(current_user.token, j)
        if job.status == "failed"
          @run.log "Job #{jid} failed"
          failed = true
        end
        %w{completed, failed}.include? job.status
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

  def publish_tarball(path)
    objectname = File.basename(path)

    File.open(path, "r") do |f|
      Swift.client.put_object objectname, f, "monsoon-automation", {"Content-Type" => 'application/gzip'}
      Swift.client.temp_url objectname, "monsoon-automation"
    end
  end
end
