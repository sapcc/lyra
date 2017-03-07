require 'rails_helper'

RSpec.describe ChefAutomationJob, type: :job do

  before(:all) {Gitmirror.cache_dir = ::File.join(tmp_path, 'gitmirror')}
  before(:each) { clean_tmp_path } #make sure previous git repositories are gone

  let(:agent) {
    ArcClient::Agent.new(
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

      add_commit("Berksfile", "source 'https://supermarket.chef.io'\ncookbook 'cookbook1', :path=> 'cookbook1/'", "add Berksfile", remote: true)
      add_commit("cookbook1/metadata.rb", "name 'cookbook1'\nversion '1.0.0'", "add metadata.rb", remote: true)
      add_commit("roles/bla.rb", "some role", "add role", remote: true)
      add_commit("data_bags/bla/item.json", "some data bag", "add data bag", remote: true)
      expect(job).to receive(:list_agents).with("bla=fasel").and_return([agent])
      expect(job).to receive(:list_agents).with("", instance_of(Array)).and_return([agent])
      expect(job).to receive(:artifact_published?).and_return false
      expect(job).to receive(:publish_artifact) do |tarball, sha|
        expect(`tar -ztf #{tarball}`.split.sort.join("\n")+"\n"). to eq(<<EOT)
./
./cookbooks/
./cookbooks/cookbook1/
./cookbooks/cookbook1/metadata.json
./data_bags/
./data_bags/bla/
./data_bags/bla/item.json
./roles/
./roles/bla.rb
EOT
      end.and_return("http://url")
      expected_payload = hash_including run_list: %w{recipe[cookbook] role[a-role]}, recipe_url: "http://url"
      expect(job).to receive(:schedule_jobs).with([agent], "chef", "zero", 3600, expected_payload).and_return(["a-job-jid"])
      ChefAutomationJob.perform_now(job)
      run.reload
      expect(run.state).to eq("executing")
      expect(run.jobs).to eq(["a-job-jid"])
      expect(run.repository_revision).to eq("7e1dc93bfb54941e4467990e3eddae254b633cc3")
      expect(TrackAutomationJob).to have_been_enqueued.with(token, job.job_id)
    end
  end

  describe "without Berksfile" do
    it "creates a tarball of the repo content" do
      chef_automation = FactoryGirl.create(:chef, repository: "file://"+remote_git_repo("test")) 
      job = ChefAutomationJob.new(token, chef_automation, "bla=fasel")
      run = FactoryGirl.create(:run, project_id: chef_automation.project_id, automation: chef_automation, job_id: job.job_id) 

      expect(job).to receive(:list_agents).with("bla=fasel").and_return([agent])
      expect(job).to receive(:list_agents).with("", instance_of(Array)).and_return([agent])
      expect(job).to receive(:artifact_published?).and_return false
      expect(job).to receive(:publish_artifact) do |tarball, sha|
        expect(`tar -ztf #{tarball}`.split.sort.join("\n")+"\n").to eq(<<EOT)
./
./configure
EOT
      end.and_return("http://url")
      expected_payload = hash_including run_list: %w{recipe[cookbook] role[a-role]}, recipe_url: "http://url"
      expect(job).to receive(:schedule_jobs).with([agent], "chef", "zero", 3600, expected_payload).and_return(["a-job-jid"])
      ChefAutomationJob.perform_now(job)
      run.reload
      expect(run.jobs).to eq(["a-job-jid"])
      expect(run.state).to eq("executing")
      expect(run.repository_revision).to eq("033e3e01379f8b81596c4367fdc91a8d22f47c85")
      expect(TrackAutomationJob).to have_been_enqueued.with(token, job.job_id)
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

  it "fails with AgentsNotFoundException when no agents found" do
    chef = FactoryGirl.create(:chef)
    job = ChefAutomationJob.new(token, chef, "bla=fasel")
    run = FactoryGirl.create(:run, job_id: job.job_id, automation: chef )
    expect(job).to receive(:list_agents).with("bla=fasel").and_return([])
    ChefAutomationJob.perform_now(job)
    run.reload

    expect(run.log).to include(::Arc::AgentsNotFoundException.new().to_s)
    expect(run.state).to eq("failed")
  end

  it "fails with ArcClient::ApiError when selector syntax wrong" do
    chef = FactoryGirl.create(:chef)
    job = ChefAutomationJob.new(token, chef, "bla=fasel")
    run = FactoryGirl.create(:run, job_id: job.job_id, automation: chef )
    exception = ArcClient::ApiError.new('{"id":"123","status":"SomeBigError","code":666,"title":"Not doing well","detail":"We are going to die","source":{"pointer":"(GET) /api/v1/kuku","parameter":"map[]"}}')
    expect(job).to receive(:list_agents).with("bla=fasel").and_raise(exception)
    ChefAutomationJob.perform_now(job)
    run.reload
    
    expect(run.log).to include(exception.to_s)
    expect(run.state).to eq("failed")
  end

end
