require 'rails_helper'
require 'git_url'

RSpec.describe ScriptAutomationJob, type: :job do
  before(:all) { 
    Gitmirror.cache_dir = ::File.join(tmp_path, 'gitmirror') 
    GitURL.class_variable_get(:@@transports).push 'file'
  }
  before(:each) { clean_tmp_path } # make sure previous git repositories are gone

  let(:agent) do
    ArcClient::Agent.new(
      'agent_id' => 'agent1',
      'facts' => {
        'hostname' => 'agent1_hostname',
        'online' => true
      },
      'arguments' => %w[arg1 arg2]
    )
  end

  it 'creates a tarball of the repo content' do
    script_automation = FactoryGirl.create(:script, repository: 'file://' + remote_git_repo('test'))
    job = ScriptAutomationJob.new(token_value, script_automation, 'bla=fasel')
    run = FactoryGirl.create(:run, token: token_value, project_id: script_automation.project_id, automation: script_automation, job_id: job.job_id)
    expect(job).to receive(:list_agents).with('bla=fasel').and_return([agent])
    expect(job).to receive(:artifact_published?).and_return false
    expect(job).to receive(:publish_artifact) do |tarball, _sha|
      expect(`cat #{tarball} | gzip -d | git get-tar-commit-id`.strip).to eq('033e3e01379f8b81596c4367fdc91a8d22f47c85')
      expect(`tar -ztf #{tarball}`).to eq(<<EOT)
configure
EOT
    end.and_return('http://url')
    expected_payload = { path: '/some_script', url: 'http://url' }
    expect(job).to receive(:schedule_jobs).with([agent], 'execute', 'tarball', 3600, expected_payload).and_return(['a-job-jid'])
    ScriptAutomationJob.perform_now(job)
    run.reload
    expect(run.state).to eq('executing')
    expect(run.jobs).to eq(['a-job-jid'])
    expect(run.repository_revision).to eq('033e3e01379f8b81596c4367fdc91a8d22f47c85')
    expect(TrackAutomationJob).to have_been_enqueued.with(token_value, job.job_id)
  end

  it 'creates a job with all parameters' do
    script_automation = FactoryGirl.create(:script, repository: 'file://' + remote_git_repo('test'), environment: { 'VAR' => 'VAL' }, arguments: %w[arg1 arg2])
    job = ScriptAutomationJob.new(token_value, script_automation, 'bla=fasel')
    run = FactoryGirl.create(:run, token: token_value, project_id: script_automation.project_id, automation: script_automation, job_id: job.job_id)
    expect(job).to receive(:list_agents).with('bla=fasel').and_return([agent])
    expect(job).to receive(:artifact_published?).and_return true
    expect(job).to receive(:artifact_url).and_return('http://url')
    expected_payload = { path: '/some_script', url: 'http://url', environment: { 'VAR' => 'VAL' }, arguments: %w[arg1 arg2] }
    expect(job).to receive(:schedule_jobs).with([agent], 'execute', 'tarball', 3600, expected_payload).and_return(['a-job-jid'])
    ScriptAutomationJob.perform_now(job)
  end
end
