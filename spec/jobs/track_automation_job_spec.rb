require 'rails_helper'

RSpec.describe TrackAutomationJob, type: :job do
  it "does nothing when run can't be found" do
    TrackAutomationJob.perform_now(token_value, 'whatever')
  end

  it 'completes a run when all arc jobs have completed' do
    run = FactoryGirl.create(:run, job_id: 'a-job-id', jobs: %w[jid1 jid2])

    job = TrackAutomationJob.new(token_value, run.job_id)
    expect(job).to receive(:arc_job).and_return(ArcClient::Job.new(status: 'complete')).exactly(2).times
    job.perform_now
    run.reload
    expect(run.state).to eq('completed')
    expect(run.jobs).to eq(%w[jid1 jid2])
  end

  it 'fails a run when one arc jobs has failed' do
    run = FactoryGirl.create(:run, job_id: 'a-job-id', jobs: %w[jid1 jid2])

    job = TrackAutomationJob.new(token_value, run.job_id)
    expect(job).to receive(:arc_job).and_return(ArcClient::Job.new(status: 'failed'), ArcClient::Job.new(status: 'complete'))
    job.perform_now
    run.reload
    expect(run.state).to eq('failed')
  end
end
