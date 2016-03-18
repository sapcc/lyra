FactoryGirl.define do

  factory :run do
    state "preparing"
    job_id "some-job-id"
    owner "some-owner"
    project_id "some-project"
  end
end
