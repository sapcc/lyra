require 'gitmirror'
require 'active_support/number_helper/number_to_human_size_converter'
require 'berkshelf/version'

class ChefAutomationJob < ActiveJob::Base
  include PrometheusMetrics
  include AutomationBase
  include MonsoonOpenstackAuthWrapper
  include POSIX::Spawn
  include Arc

  attr_accessor :perform_sleep_time

  def initialize(*arguments)
    super
    @perform_sleep_time = 10
  end

  def perform(token, chef_automation, selector)
    # freeze autoamtion state
    run.update!(automation_attributes: freeze_attr(chef_automation))

    # select nodes
    run.log "Selecting nodes using filter #{selector}:\n"
    agents = select_agents(selector)
    run.log agents.map { |a| "#{a.agent_id} #{a.facts['hostname']}" }.join("\n") + "\n"

    ensure_chef_enabled(token, agents, chef_automation.chef_version)

    # create or update local mirror of repository
    repo = Gitmirror::Repository.new(chef_automation.repository)
    repo_path = repo.mirror
    # TODO: better error message when revision is not present
    sha = execute("git --git-dir=#{repo_path} rev-parse #{chef_automation.repository_revision}").strip
    run.update_attribute(:repository_revision, sha)

    # TODO: use advisory locks and cache based on sha hash
    run.log "Another process is already creating the artifact for #{sha}. Waiting on it." if Run.advisory_lock_exists? artifact_name(sha)
    url = Run.with_advisory_lock(artifact_name(sha)) do
      if artifact_published?(artifact_name(sha))
        run.log "Using exiting artifact for revision #{sha}"
        artifact_url(artifact_name(sha))
      else
        run.log "Creating artifact for revision #{sha}"
        create_artifact repo, sha
      end
    end

    all_agents = list_agents('', %w[online hostname fqdn domain ipaddress])

    chef_payload = {
      run_list: chef_automation.run_list,
      recipe_url: url,
      attributes: chef_automation.chef_attributes,
      debug: chef_automation.debug,
      nodes: all_agents.map { |a| agent_to_node a }
    }

    # run jobs in chunks to reduce ohai accessing parallel to data service
    jobs = []
    slice_size = 3
    agents.each_slice(slice_size).with_index do |agents_chunk, _index|
      sleep(@perform_sleep_time) if _index.positive?
      jobs += schedule_jobs(agents_chunk, 'chef', 'zero', chef_automation.timeout, chef_payload)
      run.log("Scheduled #{jobs.length} #{'job'.pluralize(jobs.length)}:\n" + jobs.join("\n"))
    end
    run.log("Scheduled #{jobs.length} #{'job'.pluralize(jobs.length)}:\n" + jobs.join("\n"))

    run.update!(jobs: jobs, state: 'executing')
    # Schedule a lightweight job to track the run
    TrackAutomationJob.perform_later(token, run.job_id)
  end

  private

  def create_artifact(repo, sha)
    Dir.mktmpdir do |dir|
      checkout_dir = ::File.join dir, 'repo'
      tarball = ::File.join dir, artifact_name(sha)
      repo.checkout(checkout_dir, sha)
      if File.exist?(::File.join(checkout_dir, 'Berksfile'))
        @run.log("Berksfile detected. Running berks vendor. Using Berkshelf version #{Berkshelf::VERSION}\n")
        vendor_dir = ::File.join dir, 'berks'
        # do a berks package
        Bundler.with_clean_env do
          execute "#{ENV.fetch('BERKS_BIN', 'berks')} vendor #{vendor_dir}/cookbooks --berksfile #{checkout_dir}/Berksfile"
          %w[roles chef/roles].each do |r|
            roles_dir = File.join checkout_dir, r
            if Dir.exist? roles_dir
              @run.log("Copying #{roles_dir}\n")
              FileUtils.cp_r roles_dir, ::File.join(vendor_dir, 'roles')
            end
          end
          %w[data_bags chef/data_bags].each do |d|
            data_bags_dir = File.join checkout_dir, d
            if Dir.exist? data_bags_dir
              @run.log("Copying #{data_bags_dir}\n")
              FileUtils.cp_r data_bags_dir, ::File.join(vendor_dir, 'data_bags')
            end
          end
          @run.log("Creating tarball...\n")
          execute "tar -c -z --format=pax -C #{vendor_dir} -f #{tarball} ."
        end
      else
        @run.log("Creating tarball of repository content...\n")
        # TODO: check for correct folder structure
        # tar the checkout dir
        execute "tar -c -z --format=pax -C #{checkout_dir} -f #{tarball} ."
      end
      publish_artifact(tarball, artifact_name(sha))
    end
  end

  def agent_to_node(agent)
    # flatten our key value tags to chef's plain tags
    tags = Array(agent.tags).map { |k, v| "#{k}=#{v}" }
    tags << (agent.facts['online'] ? 'online' : 'offline')

    {
      name: agent.agent_id,
      normal: {
        tags: tags
      },
      automatic: {
        ipaddress: agent.facts['ipaddress'],
        hostname: agent.facts['hostname'],
        fqdn: agent.facts['fqdn']
      }.reject { |_k, v| v.blank? },
      run_list: []
    }
  end

  def ensure_chef_enabled(token, agents, chef_version)
    jids = agents.find_all { |a| a.facts['agents']['chef'] == 'disabled' }.map do |agent|
      # TODO: handle individual errors
      jid = arc.execute_job!(token,
                             to: agent.agent_id,
                             timeout: 600,
                             agent: 'chef',
                             action: 'enable',
                             payload: { chef_version: chef_version }.to_json)
      @run.log "Enabling chef on node #{agent.agent_id}/#{agent.facts['hostname']} (job: #{jid})"
      jid
    end
    failed = false
    # TODO: Add timeout
    loop do
      jids.delete_if do |jid|
        job = arc.find_job!(token, jid)
        if job.status == 'failed'
          @run.log "Job #{jid} failed"
          failed = true
        end
        %w[completed complete failed].include? job.status
      end
      break if jids.empty?
      sleep 5
    end
    raise "Failed to enable chef on all nodes" if failed
  end
end
