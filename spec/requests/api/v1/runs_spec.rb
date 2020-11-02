require 'rails_helper'
require 'json_matchers/rspec'
require_relative 'shared'

RSpec.describe 'Test Run API' do
  describe 'get all runs' do
    let(:automation) { FactoryGirl.create(:chef, project_id: project_id) }

    before :each do
      FactoryGirl.create(:run, automation: automation, job_id: 'some-job-id')
      FactoryGirl.create(:run, automation: automation, job_id: 'another-job-id')
      FactoryGirl.create(:run, job_id: 'a-job-in-another-project')
    end

    it 'return an authorization error 401 on wrong Auth-Code' do
      get '/api/v1/runs', headers: { 'X-Auth-Token' => 'no valid token' }
      expect(response.status).to eq(401)
    end

    context 'automation_admin' do
      before :each do
        token['project']['id'] = project_id
        token['roles'].delete_if { |h| h['id'] == 'automation_role' }
        token['roles'] << { 'id' => 'automation_role', 'name' => 'automation_admin' }
        stub_authentication
      end

      it 'returns runs for the project' do
        get '/api/v1/runs', headers: { 'X-Auth-Token' => token_value }

        expect(response).to match_response_schema('runs')
        expect(::JSON.parse(response.body).length).to eq(2)
      end

      it 'return an empty array if no runs found' do
        token['project']['id'] = '123456789'
        get '/api/v1/runs', headers: { 'X-Auth-Token' => token_value }

        expect(response).to match_response_schema('runs')
        expect(::JSON.parse(response.body).length).to eq(0)
      end

      describe 'pagination' do
        it_behaves_like 'model with pagination' do
          subject do
            # we have already created 2 valid runs on the before each
            (0..57).each do |i|
              FactoryGirl.create(:run, automation: automation, job_id: "some-job-id-#{i}")
            end
            @path = '/api/v1/runs'
          end
        end
      end
    end

    context 'automation_viewer' do
      before :each do
        token['roles'].delete_if { |h| h['id'] == 'automation_role' }
        token['roles'] << { 'id' => 'automation_role', 'name' => 'automation_viewer' }
        stub_authentication
      end

      it 'returns runs for the project' do
        get '/api/v1/runs', headers: { 'X-Auth-Token' => token_value }

        expect(response).to match_response_schema('runs')
        expect(::JSON.parse(response.body).length).to eq(2)
      end
    end

    context 'other roles' do
      before :each do
        token['roles'].delete_if { |h| h['id'] == 'automation_role' }
        token['roles'] << { 'id' => 'automation_role', 'name' => 'compute_admin' }
        stub_authentication
      end

      it 'not allowed' do
        get '/api/v1/runs', headers: { 'X-Auth-Token' => token_value }
        expect(response.status).to eq(403)
      end
    end
  end

  describe 'get run' do
    let(:automation) { FactoryGirl.create(:chef, project_id: project_id) }

    it 'return an authorization error 401 on wrong Auth-Code' do
      run = FactoryGirl.create(:run, automation: automation, job_id: 'some-job-id')
      get "/api/v1/runs/#{run.id}", headers: { 'X-Auth-Token' => 'no_valid_token' }
      expect(response.status).to eq(401)
    end

    context 'automation_admin' do
      before :each do
        token['roles'].delete_if { |h| h['id'] == 'automation_role' }
        token['roles'] << { 'id' => 'automation_role', 'name' => 'automation_admin' }
        stub_authentication
        @run = FactoryGirl.create(:run, automation: automation, job_id: 'some-job-id')
      end

      it 'returns an automation by id' do
        get "/api/v1/runs/#{@run.id}", headers: { 'X-Auth-Token' => token_value }
        expect(response.status).to eq(200)
        expect(response).to match_response_schema('run')
      end

      it 'prevents accessing runs from other projects' do
        run = FactoryGirl.create(:run, job_id: 'a-job-in-another-project')
        get "/api/v1/runs/#{run.id}", headers: { 'X-Auth-Token' => token_value }
        expect(response.status).to eq(404)
      end
    end

    context 'automation_viewer' do
      before :each do
        token['roles'].delete_if { |h| h['id'] == 'automation_role' }
        token['roles'] << { 'id' => 'automation_role', 'name' => 'automation_viewer' }
        stub_authentication
        @run = FactoryGirl.create(:run, automation: automation, job_id: 'some-job-id')
      end

      it 'returns an automation by id' do
        get "/api/v1/runs/#{@run.id}", headers: { 'X-Auth-Token' => token_value }
        expect(response.status).to eq(200)
        expect(response).to match_response_schema('run')
      end
    end

    context 'other roles' do
      before :each do
        token['roles'].delete_if { |h| h['id'] == 'automation_role' }
        token['roles'] << { 'id' => 'automation_role', 'name' => 'compute_admin' }
        stub_authentication
        @run = FactoryGirl.create(:run, automation: automation, job_id: 'some-job-id')
      end

      it 'not allowed' do
        get "/api/v1/runs/#{@run.id}", headers: { 'X-Auth-Token' => token_value }
        expect(response.status).to eq(403)
      end
    end
  end

  describe 'create run' do
    let(:automation) { FactoryGirl.create(:chef, project_id: project_id) }

    it 'return an authorization error 401 on wrong Auth-Code' do
      post '/api/v1/runs', params: { automation_id: automation.id }
      expect(response.status).to eq(401)
    end

    context 'automation_admin' do
      before :each do
        token['roles'].delete_if { |h| h['id'] == 'automation_role' }
        token['roles'] << { 'id' => 'automation_role', 'name' => 'automation_admin' }
        stub_authentication
      end

      it 'creates an automation run' do
        post '/api/v1/runs', params: { automation_id: automation.id }, headers: { 'X-Auth-Token' => token_value }
        expect(response.status).to eq(201)
        expect(response).to match_response_schema('run')
      end

      it 'creates a run for an existing github.wdf.sap.corp automation without authentication' do
        a = FactoryGirl.build(:chef, project_id: project_id, repository: 'git://github.wdf.sap.corp').tap { |a| a.save(validate:false) }
        post '/api/v1/runs', params: { automation_id: a.id }, headers: { 'X-Auth-Token' => token_value }
        expect(response.status).to eq(201)
      end

      it 'ensures runs are only created for automations in the same project' do
        post '/api/v1/runs', params: { automation_id: FactoryGirl.create(:chef).id }, headers: { 'X-Auth-Token' => token_value }
        expect(response.status).to eq(404)
      end
    end

    context 'automation_viewer' do
      before :each do
        token['roles'].delete_if { |h| h['id'] == 'automation_role' }
        token['roles'] << { 'id' => 'automation_role', 'name' => 'automation_viewer' }
        stub_authentication
      end

      it 'not allowed' do
        post '/api/v1/runs', params: { automation_id: automation.id }, headers: { 'X-Auth-Token' => token_value }
        expect(response.status).to eq(403)
      end
    end

    context 'other roles' do
      before :each do
        token['roles'].delete_if { |h| h['id'] == 'automation_role' }
        token['roles'] << { 'id' => 'automation_role', 'name' => 'compute_admin' }
        stub_authentication
      end

      it 'not allowed' do
        post '/api/v1/runs', params: { automation_id: automation.id }, headers: { 'X-Auth-Token' => token_value }
        expect(response.status).to eq(403)
      end
    end
  end
end
