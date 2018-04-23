require 'rails_helper'

RSpec.describe 'rake run:cleanup', type: :task do
  let(:task) { Rake::Task['run:cleanup'] }

  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'remove runs older than 30 days keeping 5 most recent' do
    chef_automation = FactoryGirl.create(:chef, repository: 'file://' + remote_git_repo('test'))
    10.times do |i|
      date = Date.today - (30 + i)
      FactoryGirl.create(:run, token: token, project_id: chef_automation.project_id, automation: chef_automation, job_id: "job_id_#{i}", created_at: date, updated_at: date)
    end
    expect(Run.all.length).to eq(10)
    task.invoke
    expect(Run.all.length).to eq(5)

    target_date = Date.today - (30 + 5)
    Run.all.each do |run|
      expect(run.updated_at.to_i).to be > target_date.to_time.to_i
    end
  end
end
