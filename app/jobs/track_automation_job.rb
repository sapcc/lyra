class TrackAutomationJob < ActiveJob::Base

  include MonsoonOpenstackAuthWrapper
  include ArcClient

  def perform(token, run_jid)
    run = Run.find_by_job_id(run_jid)
    return unless run #Run not found -> exit 
    jids = Array(run.jobs)
    failed = []
    completed = []
    loop do
      jids.keep_if do |j|
        job = arc_job(j) #TODO: handle fatal api errors (token expired, 404, etc)
        failed << j if job.failed?
        completed << j if job.completed?
        job.running?
      end
      break if jids.empty?
      sleep 5
    end
    run.update!(state: failed.empty? ? 'completed' : 'failed')

  end

  private

  def arc_job id
    arc.find_job(id)
  end
  
end
