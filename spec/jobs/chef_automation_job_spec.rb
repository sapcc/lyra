require 'rails_helper'

RSpec.describe ChefAutomationJob, type: :job do

  before(:each) { clean_tmp_path } #make sure previous git repositories are gone

  let(:chef) { FactoryGirl.create(:chef)  }

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

  describe "with Berkfile" do
    it "creates a tarball of the repo content" do
      chef_automation = FactoryGirl.create(:chef, repository: "file://"+remote_git_repo("test")) 

      add_commit("Berksfile", "source 'https://supermarket.chef.io'\nmetadata", "add Berksfile", remote: true)
      add_commit("metadata.rb", "name 'cookbook1'\nversion '1.0.0'", "add metadata.rb", remote: true)
      expect_any_instance_of(ChefAutomationJob).to receive(:list_agents).with("bla=fasel").and_return([agent])
      expect_any_instance_of(ChefAutomationJob).to receive(:publish_tarball).with(instance_of(String)).and_return("http://url")
      expect_any_instance_of(ChefAutomationJob).to receive(:schedule_jobs).with([agent], chef_automation, "http://url").and_return(["a-job-jid"])
      ChefAutomationJob.perform_later(token, "someowner", chef_automation, "bla=fasel")
      run = Run.first
      expect(run.project_id).to eq(chef_automation.project_id)
      expect(run.automation_id).to eq(chef_automation.id)
      expect(run.owner).to eq("someowner")
      expect(run.jobs).to eq(["a-job-jid"])
      expect(run.state).to eq("executing")
    end
  end

  describe "without Berksfile" do
    it "creates a tarball of the repo content" do
      chef_automation = FactoryGirl.create(:chef, repository: "file://"+remote_git_repo("test")) 

      expect_any_instance_of(ChefAutomationJob).to receive(:list_agents).with("bla=fasel").and_return([agent])
      expect_any_instance_of(ChefAutomationJob).to receive(:publish_tarball).with(instance_of(String)).and_return("http://url")
      expect_any_instance_of(ChefAutomationJob).to receive(:schedule_jobs).with([agent], chef_automation, "http://url").and_return(["a-job-jid"])
      ChefAutomationJob.perform_later(token, "someowner", chef_automation, "bla=fasel")
      run = Run.first
      expect(run.project_id).to eq(chef_automation.project_id)
      expect(run.automation_id).to eq(chef_automation.id)
      expect(run.owner).to eq("someowner")
      expect(run.jobs).to eq(["a-job-jid"])
      expect(run.state).to eq("executing")
    end
  end

  it "fails when an agent is offline" do
    agent.facts["online"]=false
    expect_any_instance_of(ChefAutomationJob).to receive(:list_agents).with("bla=fasel").and_return([agent])
    ChefAutomationJob.perform_later(token, "someowner", chef, "bla=fasel")
    run = Run.first
    expect(run.state).to eq("failed")
  end


end
