require 'rails_helper'

RSpec.describe ChefAutomationJob, type: :job do

  before(:all) {Gitmirror.cache_dir = ::File.join(tmp_path, 'gitmirror')}
  before(:each) { clean_tmp_path } #make sure previous git repositories are gone

  let(:agent) {
    RubyArcClient::Agent.new(
      "agent_id"=> "agent1",
      "facts" => { 
        "hostname" => "agent1_hostname", 
        "online" => true,
        "agents" => {
          "chef": "enabled"
        } 
      }
    )
  }

  pending "simplify the factory setup"

  describe "with Berkfile" do
    it "creates a tarball of the repo content" do
      chef_automation = FactoryGirl.create(:chef, repository: "file://"+remote_git_repo("test")) 
      job = ChefAutomationJob.new(token, chef_automation, "bla=fasel")
      run =  FactoryGirl.create(:run, token: token, project_id: chef_automation.project_id, automation: chef_automation, job_id: job.job_id) 

      add_commit("Berksfile", "source 'https://supermarket.chef.io'\nmetadata", "add Berksfile", remote: true)
      add_commit("metadata.rb", "name 'cookbook1'\nversion '1.0.0'", "add metadata.rb", remote: true)
      expect(job).to receive(:list_agents).with("bla=fasel").and_return([agent])
      expect(job).to receive(:publish_tarball) do |tarball|
        expect(`tar -ztf #{tarball}`). to eq(<<EOT)
.
cookbooks
cookbooks/cookbook1
cookbooks/cookbook1/Berksfile
cookbooks/cookbook1/Berksfile.lock
cookbooks/cookbook1/configure
cookbooks/cookbook1/metadata.json
EOT
      end.and_return("http://url")
      expect(job).to receive(:schedule_jobs).with([agent], chef_automation, "http://url").and_return(["a-job-jid"])
      ChefAutomationJob.perform_now(job)
      run.reload
      expect(run.state).to eq("executing")
      expect(run.jobs).to eq(["a-job-jid"])
      expect(run.repository_revision).to eq("bb21a99e7b1e60fbc80630440d453583acae7e2c")
    end
  end

  describe "without Berksfile" do
    it "creates a tarball of the repo content" do
      chef_automation = FactoryGirl.create(:chef, repository: "file://"+remote_git_repo("test")) 
      job = ChefAutomationJob.new(token, chef_automation, "bla=fasel")
      run = FactoryGirl.create(:run, project_id: chef_automation.project_id, automation: chef_automation, job_id: job.job_id) 

      expect(job).to receive(:list_agents).with("bla=fasel").and_return([agent])
      expect(job).to receive(:publish_tarball) do |tarball|
        expect(`tar -ztf #{tarball}`).to eq(<<EOT)
./
./configure
EOT
      end.and_return("http://url")
      expect(job).to receive(:schedule_jobs).with([agent], chef_automation, "http://url").and_return(["a-job-jid"])
      ChefAutomationJob.perform_now(job)
      run.reload
      expect(run.jobs).to eq(["a-job-jid"])
      expect(run.state).to eq("executing")
      expect(run.repository_revision).to eq("033e3e01379f8b81596c4367fdc91a8d22f47c85")
    end
  end

  it "fails when an agent is offline" do
    agent.facts["online"]=false
    chef = FactoryGirl.create(:chef)
    job = ChefAutomationJob.new(token, chef, "bla=fasel")
    run = FactoryGirl.create(:run, job_id: job.job_id, automation: chef )
    expect(job).to receive(:list_agents).with("bla=fasel").and_return([agent])
    ChefAutomationJob.perform_now(job)
    run.reload
    expect(run.state).to eq("failed")
  end


end
