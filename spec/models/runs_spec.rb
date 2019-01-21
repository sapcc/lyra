require 'rails_helper'

RSpec.describe Run, type: :model do
  let(:run) { FactoryGirl.create(:run, job_id: 'a-job_id') }

  it 'memorizes the project_id' do
    expect(run.project_id).to eq(run.automation.project_id)
    new_automation = FactoryGirl.create(:chef, project_id: 'another project')
    run.update(automation: new_automation)
    expect(run.project_id).to eq(new_automation.project_id)
  end

  it 'appends logs' do
    run.log 'a string'
    run.log "a string with eol\n"
    run.log 'third string'
    run.reload
    expect(run.log).to eq("a string\na string with eol\nthird string\n")
  end

  it 'requires an owner' do
    run.owner = nil
    expect(run).to be_invalid
  end

  it 'serializer an owner_object' do
    run = FactoryGirl.create(:run, job_id: 'a-job_id', owner: current_user)

    expect(run.owner.keys).to match_array(%w[id name domain_id domain_name])
  end

  it 'requires an automation' do
    run.automation = nil
    expect(run).to be_invalid
  end

  context 'without job_id' do
    let(:run) { FactoryGirl.create(:run, token: token_value) }

    it 'has a valid factory' do
      expect(run).to be_valid
    end

    it 'requires a token' do
      expect(FactoryGirl.build(:run, token: nil)).to be_invalid
    end

    it 'creates an automation job' do
      # inject fixed job_id
      expect(SecureRandom).to receive(:uuid).and_return('768aa68e-f717-4cac-8708-f0a1ed60a17b')
      expect(ChefAutomationJob).to have_been_enqueued.with(token_value, global_id(run.automation), 'bla=fasel')

      expect(run.job_id).to eq('768aa68e-f717-4cac-8708-f0a1ed60a17b')
    end

    # this can't be tested with the normal :test queue adapter I think
    # We need to run the que test adapter without any workers to see if everything runs in a transaction
    pending 'it does not create a job if saving fails'
  end

  context 'with job_id' do
    let(:run) { FactoryGirl.create(:run, job_id: 'a-job_id') }

    it 'has a valid factory' do
      expect(run).to be_valid
    end

    it 'does not create an automation job' do
      run
      expect(ChefAutomationJob).not_to have_been_enqueued
    end
  end
end
