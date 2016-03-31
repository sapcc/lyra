require 'rails_helper'
require "json_matchers/rspec"

RSpec.describe "Test Run API" do


  let(:automation) { FactoryGirl.create(:chef, project_id: project_id) }

  it 'creates an automation run' do
    post '/api/v1/runs', {automation_id: automation.id}, {'X-Auth-Token' => token}
    expect(response.status).to eq(201) 
    expect(response).to match_response_schema("run")
  end

  it 'ensures runs are only created for automations in the same project' do
    post '/api/v1/runs', {automation_id: FactoryGirl.create(:chef).id}, {'X-Auth-Token' => token}
    expect(response.status).to eq(404) 
  end

  it "returns an automation by id" do
    run = FactoryGirl.create(:run, automation: automation, job_id: "some-job-id")
    get "/api/v1/runs/#{run.id}", nil, {'X-Auth-Token' => token}
    expect(response.status).to eq(200) 
    expect(response).to match_response_schema("run")
  end
  
  it "prevents accessing runs from other projects" do
    run = FactoryGirl.create(:run, job_id: "a-job-in-another-project")
    get "/api/v1/runs/#{run.id}", nil, {'X-Auth-Token' => token}
    expect(response.status).to eq(404) 
  end

  it "returns runs for the project" do
    FactoryGirl.create(:run, automation: automation, job_id: "some-job-id")
    FactoryGirl.create(:run, automation: automation, job_id: "another-job-id")
    FactoryGirl.create(:run, job_id: "a-job-in-another-project")

    get '/api/v1/runs', nil, {'X-Auth-Token' => token}

    expect(response).to match_response_schema("runs")
    expect(::JSON.parse(response.body).length).to eq(2) 

  end

  it "returns 401 on wrong Auth-Code" do
    post '/api/v1/runs', nil, {'X-Auth-Token' => "wrong_token"}
  end
  

end
