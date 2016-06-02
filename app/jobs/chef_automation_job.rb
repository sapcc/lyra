require 'gitmirror'
require 'active_support/number_helper/number_to_human_size_converter'

class ChefAutomationJob < ActiveJob::Base

  include AutomationBase
  include MonsoonOpenstackAuthWrapper
  include POSIX::Spawn
  include ArcClient

  def perform(token, chef_automation, selector)

    run.log "Selecting nodes using filter #{selector}:\n"
    agents = select_agents(selector)
    run.log agents.map {|a| "#{a.agent_id} #{a.facts["hostname"]}"}.join("\n") + "\n"

    ensure_chef_enabled(token, agents, chef_automation.chef_version)
     
    #create or update local mirror of repository
    repo = Gitmirror::Repository.new(chef_automation.repository)
    repo_path = repo.mirror()
    #TODO better error message when revision is not present
    sha = execute("git --git-dir=#{repo_path} rev-parse #{chef_automation.repository_revision}").strip
    run.update_attribute(:repository_revision, sha)

    #TODO: use advisory locks and cache based on sha hash
    run.log "Another process is already creating the artifact for #{sha}. Waiting on it." if Run.advisory_lock_exists? artifact_name(sha)
    url = Run.with_advisory_lock(artifact_name(sha)) do
      if artifact_published?(artifact_name(sha))
        run.log "Re-using exiting artifact for revision #{sha}"
        artifact_url(artifact_name(sha))
      else
        run.log "Creating artifact for revision #{sha}"
        create_artifact repo, sha
      end 
    end

    chef_payload = {
      run_list: chef_automation.run_list,
      recipe_url: url,
      attributes: chef_automation.chef_attributes,
      debug: false,
    }
    jobs = schedule_jobs(agents, 'chef', 'zero', chef_automation.timeout, chef_payload)
    run.log("Scheduled #{jobs.length} #{'job'.pluralize(jobs.length)}:\n" + jobs.join("\n"))

    run.update!(jobs: jobs, state: 'executing')
    #Schedule a lightweight job to track the run 
    TrackAutomationJob.perform_later(token, run.job_id)

  end 

  private

  def create_artifact(repo, sha)
    Dir.mktmpdir do |dir|
      checkout_dir = ::File.join dir, "repo"
      tarball = ::File.join dir, artifact_name(sha) 
      repo.checkout(checkout_dir, sha)
      if File.exist?(::File.join(checkout_dir, 'Berksfile'))
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
      publish_artifact(tarball, sha)
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

end
