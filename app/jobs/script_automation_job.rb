# frozen_string_literal: true

class ScriptAutomationJob < ActiveJob::Base
  include PrometheusMetrics
  include AutomationBase
  include MonsoonOpenstackAuthWrapper
  include POSIX::Spawn
  include Arc

  def perform(token, script_automation, selector)
    # freeze autoamtion state
    run.update!(automation_attributes: freeze_attr(script_automation))

    # select nodes
    run.log "Selecting nodes using filter #{selector}:\n"
    agents = select_agents(selector)
    run.log agents.map { |a| "#{a.agent_id} #{a.facts['hostname']}" }.join("\n") + "\n"

    repo = $repository_semaphore.get(script_automation.repository).synchronize do
      Gitmirror::Repository.new(script_automation.repository)
    end

    repo_path = if script_automation.repository_authentication_enabled
                  repo.mirror(script_automation.repository_credentials)
                else
                  repo.mirror
                end

    # TODO: better error message when revision is not present
    sha = execute('git', "--git-dir=#{repo_path}", 'rev-parse', script_automation.repository_revision).strip
    run.update_attribute(:repository_revision, sha)

    run.log "Another process is already building the artifact for #{sha}. Waiting..." if Run.advisory_lock_exists? artifact_name(sha)
    url = Run.with_advisory_lock(artifact_name(sha)) do
      if artifact_published?(artifact_name(sha))
        run.log "Using exiting artifact for revision #{sha}"
        artifact_url(artifact_name(sha))
      else
        run.log "Creating artifact for revision #{sha}"
        create_artifact repo, sha
      end
    end

    execute_payload = {
      path: script_automation.path,
      arguments: script_automation.arguments,
      environment: script_automation.environment,
      url: url
    }.delete_if { |_k, v| v.blank? }

    jobs = schedule_jobs(agents, 'execute', 'tarball', script_automation.timeout, execute_payload)
    run.log("Scheduled #{jobs.length} #{'job'.pluralize(jobs.length)}:\n" + jobs.join("\n"))

    run.update!(jobs: jobs, state: 'executing')
    # Schedule a lightweight job to track the run
    TrackAutomationJob.perform_later(token, run.job_id)
  end

  private

  def create_artifact(repo, sha)
    Dir.mktmpdir do |dir|
      tarball = ::File.join(dir, artifact_name(sha))
      execute('git', "--git-dir=#{repo.path}", 'archive', '-o', tarball, sha)
      publish_artifact(tarball, artifact_name(sha))
    end
  end
end
