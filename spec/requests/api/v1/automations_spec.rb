# frozen_string_literal: true

require 'rails_helper'
require_relative 'shared'

RSpec.describe 'Test Automations API' do
  describe 'Get all automations' do
    before :each do
      @script_automation = FactoryGirl.create(:script, project_id: project_id, repository_credentials: 'secret_password')
      @chef_automation = FactoryGirl.create(:chef, project_id: project_id, repository_credentials: 'secret_password')
      FactoryGirl.create(:chef, project_id: 'some_other_project')
    end

    context 'automation_admin' do
      before :each do
        token['project']['id'] = project_id
        token['roles'].delete_if { |h| h['id'] == 'automation_role' }
        token['roles'] << { 'id' => 'automation_role', 'name' => 'automation_admin' }
        stub_authentication
      end

      it 'return all automation' do
        get '/api/v1/automations', headers: { 'X-Auth-Token' => token_value }
        expect(response).to be_successful
        json = JSON.parse(response.body)

        expect(json.length).to eq(2)
        expect(json[0]['id']).to eq(@chef_automation.id)
        expect(json[1]['id']).to eq(@script_automation.id)
      end

      it 'return an empty array if no automations found' do
        token['project']['id'] = '123456789'
        get '/api/v1/automations', headers: { 'X-Auth-Token' => token_value }
        expect(response).to be_successful
        json = JSON.parse(response.body)
        expect(json.length).to eq(0)
      end

      it 'displays repository_authentication_enabled if repository_credentials is set' do
        get '/api/v1/automations', headers: { 'X-Auth-Token' => token_value }
        expect(response).to be_successful
        json = JSON.parse(response.body)

        expect(json.length).to eq(2)
        expect(json[0]['repository_credentials']).to eq(nil)
        expect(json[0]['repository_authentication_enabled']).to eq(true)
        expect(json[1]['repository_credentials']).to eq(nil)
        expect(json[1]['repository_authentication_enabled']).to eq(true)
      end
    end

    context 'automation_viewer' do
      before :each do
        token['project']['id'] = project_id
        token['roles'].delete_if { |h| h['id'] == 'automation_role' }
        token['roles'] << { 'id' => 'automation_role', 'name' => 'automation_viewer' }
        stub_authentication
      end

      it 'return all automation' do
        get '/api/v1/automations', headers: { 'X-Auth-Token' => token_value }
        expect(response).to be_successful
        json = JSON.parse(response.body)
        expect(json.length).to eq(2)
        expect(json[0]['id']).to eq(@chef_automation.id)
        expect(json[1]['id']).to eq(@script_automation.id)
      end

      it 'return an empty array if no automations found' do
        token['project']['id'] = '123456789'
        get '/api/v1/automations', headers: { 'X-Auth-Token' => token_value }
        expect(response).to be_successful
        json = JSON.parse(response.body)
        expect(json.length).to eq(0)
      end

      it 'displays repository_authentication_enabled if repository_credentials is set' do
        get '/api/v1/automations', headers: { 'X-Auth-Token' => token_value }
        expect(response).to be_successful
        json = JSON.parse(response.body)

        expect(json.length).to eq(2)
        expect(json[0]['repository_credentials']).to eq(nil)
        expect(json[0]['repository_authentication_enabled']).to eq(true)
        expect(json[1]['repository_credentials']).to eq(nil)
        expect(json[1]['repository_authentication_enabled']).to eq(true)
      end
    end

    context 'other roles' do
      before :each do
        token['project']['id'] = project_id
        token['roles'].delete_if { |h| h['id'] == 'automation_role' }
        token['roles'] << { 'id' => 'automation_role', 'name' => 'compute_admin' }
        stub_authentication
      end

      it 'not allowed' do
        get '/api/v1/automations', headers: { 'X-Auth-Token' => token_value }
        expect(response).to_not be_successful
        expect(response.status).to eq(403)
      end
    end

    it 'return an authorization error 401' do
      get '/api/v1/automations'
      expect(response.status).to eq(401)
    end

    it 'return status forbiden if token has no project' do
      # stub project id
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('current_user').as_null_object)
      get '/api/v1/automations', headers: { 'X-Auth-Token' => token_value }
      expect(response.status).to eq(403)
    end

    describe 'pagination' do
      before :each do
        token['project']['id'] = project_id
        token['roles'].delete_if { |h| h['id'] == 'automation_role' }
        token['roles'] << { 'id' => 'automation_role', 'name' => 'automation_admin' }
        stub_authentication
      end
      it_behaves_like 'model with pagination' do
        subject do
          # we have already created 2 valid runs on the before each
          (0..28).each do |_i|
            FactoryGirl.create(:script, project_id: project_id)
            FactoryGirl.create(:chef, project_id: project_id)
          end
          @path = '/api/v1/automations'
        end
      end
    end
  end

  describe 'show an automation' do
    before :each do
      @script_automation = FactoryGirl.create(:script, name: 'production', project_id: project_id)
      @chef_automation = FactoryGirl.create(:chef, name: 'chef_automation', project_id: project_id)
    end

    context 'automation_admin' do
      before :each do
        token['project']['id'] = project_id
        token['roles'].delete_if { |h| h['id'] == 'automation_role' }
        token['roles'] << { 'id' => 'automation_role', 'name' => 'automation_admin' }
        stub_authentication
      end

      context 'Script' do
        it 'return the automation' do
          get "/api/v1/automations/#{@script_automation.id}", headers: { 'X-Auth-Token' => token_value }
          json = JSON.parse(response.body)

          expect(response).to be_successful
          expect(json['id']).to be == @script_automation.id
          expect(json['name']).to be == @script_automation.name
          expect(json['type']).to be == @script_automation.class.name
          expect(json['project_id']).to be == project_id
          expect(json['repository']).to be == @script_automation.repository
        end

        it 'displays repository_authentication_enabled if repository_credentials is set' do
          test_automation = FactoryGirl.create(:script, name: 'test_credential', project_id: project_id, repository_credentials: 'secret_password')
          get "/api/v1/automations/#{test_automation.id}", headers: { 'X-Auth-Token' => token_value }
          json = JSON.parse(response.body)
          expect(response).to be_successful
          expect(json['repository_credentials']).to eq(nil)
          expect(json['repository_authentication_enabled']).to eq(true)
        end

        it 'returns blank if repository_credentials is NOT set' do
          test_automation = FactoryGirl.create(:script, name: 'test_credential', project_id: project_id)
          get "/api/v1/automations/#{test_automation.id}", headers: { 'X-Auth-Token' => token_value }
          json = JSON.parse(response.body)
          expect(response).to be_successful
          expect(json['repository_credentials']).to eq(nil)
          expect(json['repository_authentication_enabled']).to eq(false)
        end
      end

      context 'Chef' do
        it 'return an automation' do
          get "/api/v1/automations/#{@chef_automation.id}", headers: { 'X-Auth-Token' => token_value }
          json = JSON.parse(response.body)

          expect(response).to be_successful
          expect(json['id']).to be == @chef_automation.id
          expect(json['name']).to be == @chef_automation.name
          expect(json['type']).to be == @chef_automation.class.name
          expect(json['project_id']).to be == project_id
          expect(json['repository']).to be == @chef_automation.repository
        end

        it 'displays repository_authentication_enabled if repository_credentials is set' do
          test_automation = FactoryGirl.create(:chef, name: 'test_credential', project_id: project_id, repository_credentials: 'secret_password')
          get "/api/v1/automations/#{test_automation.id}", headers: { 'X-Auth-Token' => token_value }
          json = JSON.parse(response.body)
          expect(response).to be_successful
          expect(json['repository_credentials']).to eq(nil)
          expect(json['repository_authentication_enabled']).to eq(true)
        end

        it 'returns blank if repository_credentials is NOT set' do
          test_automation = FactoryGirl.create(:chef, name: 'test_credential', project_id: project_id)
          get "/api/v1/automations/#{test_automation.id}", headers: { 'X-Auth-Token' => token_value }
          json = JSON.parse(response.body)
          expect(response).to be_successful
          expect(json['repository_credentials']).to eq(nil)
          expect(json['repository_authentication_enabled']).to eq(false)
        end
      end

      it 'returns a 404 if automation not found' do
        get '/api/v1/automations/non_existing_automation', headers: { 'X-Auth-Token' => token_value }
        expect(response.status).to eq(404)
      end
    end

    context 'automation_viewer' do
      before :each do
        token['project']['id'] = project_id
        token['roles'].delete_if { |h| h['id'] == 'automation_role' }
        token['roles'] << { 'id' => 'automation_role', 'name' => 'automation_viewer' }
        stub_authentication
      end

      context 'Script' do
        it 'return the automation' do
          get "/api/v1/automations/#{@script_automation.id}", headers: { 'X-Auth-Token' => token_value }
          json = JSON.parse(response.body)

          expect(response).to be_successful
          expect(json['id']).to be == @script_automation.id
          expect(json['name']).to be == @script_automation.name
          expect(json['type']).to be == @script_automation.class.name
          expect(json['project_id']).to be == project_id
          expect(json['repository']).to be == @script_automation.repository
        end
        it 'displays repository_authentication_enabled if repository_credentials is set' do
          test_automation = FactoryGirl.create(:script, name: 'test_credential', project_id: project_id, repository_credentials: 'secret_password')
          get "/api/v1/automations/#{test_automation.id}", headers: { 'X-Auth-Token' => token_value }
          json = JSON.parse(response.body)
          expect(response).to be_successful
          expect(json['repository_credentials']).to eq(nil)
          expect(json['repository_authentication_enabled']).to eq(true)
        end

        it 'returns blank if repository_credentials is NOT set' do
          test_automation = FactoryGirl.create(:script, name: 'test_credential', project_id: project_id)
          get "/api/v1/automations/#{test_automation.id}", headers: { 'X-Auth-Token' => token_value }
          json = JSON.parse(response.body)
          expect(response).to be_successful
          expect(json['repository_credentials']).to eq(nil)
          expect(json['repository_authentication_enabled']).to eq(false)
        end
      end

      context 'Chef' do
        it 'return an automation' do
          get "/api/v1/automations/#{@chef_automation.id}", headers: { 'X-Auth-Token' => token_value }
          json = JSON.parse(response.body)

          expect(response).to be_successful
          expect(json['id']).to be == @chef_automation.id
          expect(json['name']).to be == @chef_automation.name
          expect(json['type']).to be == @chef_automation.class.name
          expect(json['project_id']).to be == project_id
          expect(json['repository']).to be == @chef_automation.repository
        end
        it 'displays repository_authentication_enabled if repository_credentials is set' do
          test_automation = FactoryGirl.create(:chef, name: 'test_credential', project_id: project_id, repository_credentials: 'secret_password')
          get "/api/v1/automations/#{test_automation.id}", headers: { 'X-Auth-Token' => token_value }
          json = JSON.parse(response.body)
          expect(response).to be_successful
          expect(json['repository_credentials']).to eq(nil)
          expect(json['repository_authentication_enabled']).to eq(true)
        end

        it 'returns blank if repository_credentials is NOT set' do
          test_automation = FactoryGirl.create(:chef, name: 'test_credential', project_id: project_id)
          get "/api/v1/automations/#{test_automation.id}", headers: { 'X-Auth-Token' => token_value }
          json = JSON.parse(response.body)
          expect(response).to be_successful
          expect(json['repository_credentials']).to eq(nil)
          expect(json['repository_authentication_enabled']).to eq(false)
        end
      end

      it 'returns a 404 if automation not found' do
        get '/api/v1/automations/non_existing_automation', headers: { 'X-Auth-Token' => token_value }
        expect(response.status).to eq(404)
      end
    end

    context 'other roles' do
      before :each do
        token['project']['id'] = project_id
        token['roles'].delete_if { |h| h['id'] == 'automation_role' }
        token['roles'] << { 'id' => 'automation_role', 'name' => 'compute_admin' }
        stub_authentication
      end

      context 'Script' do
        it 'not allowed' do
          get "/api/v1/automations/#{@script_automation.id}", headers: { 'X-Auth-Token' => token_value }
          expect(response.status).to eq(403)
        end
      end

      context 'Chef' do
        it 'return an automation' do
          get "/api/v1/automations/#{@chef_automation.id}", headers: { 'X-Auth-Token' => token_value }
          expect(response.status).to eq(403)
        end
      end
    end

    it 'return an authorization error 401' do
      get "/api/v1/automations/#{@script_automation.name}"
      expect(response.status).to eq(401)
    end

    it 'return status forbiden if taken has no project' do
      # stub project id
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('current_user').as_null_object)
      get '/api/v1/automations/some_automation', headers: { 'X-Auth-Token' => token_value }
      expect(response.status).to eq(403)
    end
  end

  describe 'create an automation' do
    describe 'script' do
      context 'automation_admin' do
        before :each do
          @automation = FactoryGirl.create(:script, environment: { test: 'test' }.to_json, repository_credentials: 'secret_password')
          @automation.attributes.delete('id')
          token['project']['id'] = project_id
          token['roles'].delete_if { |h| h['id'] == 'automation_role' }
          token['roles'] << { 'id' => 'automation_role', 'name' => 'automation_admin' }
          stub_authentication
        end

        it 'creates an automation' do
          post '/api/v1/automations/', params: @automation.attributes, headers: { 'X-Auth-Token' => token_value }
          expect(response.status).to eq(201)
          json = JSON.parse(response.body)
          expect(json['type']).to be == @automation.class.name
          expect(json['name']).to be == @automation.name
          expect(json['repository']).to be == @automation.repository
          expect(json['repository_revision']).to be == @automation.repository_revision
          expect(json['timeout']).to be == @automation.timeout
          expect(json['path']).to be == @automation.path
          expect(json['arguments']).to be == @automation.arguments
          expect(json['environment']).to be == @automation.environment
          expect(json['repository_credentials']).to eq(nil)
          expect(json['repository_authentication_enabled']).to eq(true)
        end

        it 'creates an automation with default false repository_authentication_enabled' do
          new_automation = FactoryGirl.create(:script, environment: { test: 'test' }.to_json, repository_credentials: '')
          post '/api/v1/automations/', params: new_automation.attributes, headers: { 'X-Auth-Token' => token_value }
          expect(response.status).to eq(201)
          json = JSON.parse(response.body)
          expect(json['repository_credentials']).to eq(nil)
          expect(json['repository_authentication_enabled']).to eq(false)
        end

        it 'creates an automation in the right project' do
          # name already exists
          post '/api/v1/automations', params: { type: 'Script', name: 'prod_auto', path: 'script_path', repository: 'https://miau' }, headers: { 'X-Auth-Token' => token_value }
          json = JSON.parse(response.body)

          expect(response.status).to eq(201)
          expect(json['type']).to be == 'Script'
          expect(json['project_id']).to be == project_id
        end

        it 'return an authorization error 401 if token not valid' do
          post '/api/v1/automations/', params: { type: 'Script', name: 'prod_auto', path: 'script_path', repository: 'https://miau' }, headers: { 'X-Auth-Token' => 'token_no_valid' }
          expect(response.status).to eq(401)
        end

        it 'return status forbiden if token has no project' do
          # stub project id
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('current_user').as_null_object)
          post '/api/v1/automations/', params: { type: 'Script', name: 'prod_auto', path: 'script_path', repository: 'https://miau' }, headers: { 'X-Auth-Token' => token_value }
          expect(response.status).to eq(403)
        end
      end

      context 'automation_viewer' do
        before :each do
          token['project']['id'] = project_id
          token['roles'].delete_if { |h| h['id'] == 'automation_role' }
          token['roles'] << { 'id' => 'automation_role', 'name' => 'automation_viewer' }
          stub_authentication
        end

        it 'not allowed' do
          post '/api/v1/automations', params: { type: 'Script', name: 'prod_auto', path: 'script_path', repository: 'https://miau' }, headers: { 'X-Auth-Token' => token_value }
          expect(response).to_not be_successful
          expect(response.status).to eq(403)
        end
      end

      context 'other roles' do
        before :each do
          token['project']['id'] = project_id
          token['roles'].delete_if { |h| h['id'] == 'automation_role' }
          token['roles'] << { 'id' => 'automation_role', 'name' => 'compute_admin' }
          stub_authentication
        end

        it 'not allowed' do
          post '/api/v1/automations', params: { type: 'Script', name: 'prod_auto', path: 'script_path', repository: 'https://miau' }, headers: { 'X-Auth-Token' => token_value }
          expect(response).to_not be_successful
          expect(response.status).to eq(403)
        end
      end

      describe 'validations' do
        before :each do
          token['project']['id'] = project_id
          token['roles'].delete_if { |h| h['id'] == 'automation_role' }
          token['roles'] << { 'id' => 'automation_role', 'name' => 'automation_admin' }
          stub_authentication
        end

        it 'check name error show up' do
          name = 'production'
          FactoryGirl.create(:script, name: name, project_id: project_id)

          # name already exists
          post '/api/v1/automations/', params: { type: 'Script', name: name, project_id: project_id, path: 'script_path', repository: 'https://miau', tags: '{}'.to_json }, headers: { 'X-Auth-Token' => token_value }
          json = JSON.parse(response.body)
          expect(response.status).to eq(422)
          expect(json['errors']['name']).not_to be_empty
        end

        it 'checks git url error shows up' do
          post '/api/v1/automations/', params: { type: 'Script', name: 'test_automation', project_id: project_id, path: 'script_path', repository: 'not_a_url', tags: '{}'.to_json }, headers: { 'X-Auth-Token' => token_value }
          json = JSON.parse(response.body)

          expect(response.status).to eq(422)
          expect(json['errors']['repository']).not_to be_empty
        end

        it 'tags are filtered out' do
          post '/api/v1/automations/', params: { type: 'Script', name: 'test_automation', project_id: project_id, path: 'script_path', repository: 'http://uri', tags: 'not_json' }, headers: { 'X-Auth-Token' => token_value }
          json = JSON.parse(response.body)

          expect(response.status).to eq(201)
          expect(json['tags']).to be_nil
        end

        it 'ignores invalid environment' do
          post '/api/v1/automations/', params: { type: 'Script', name: 'test_automation', project_id: project_id, path: 'script_path', repository: 'https://miau', environment: '{ hase: ["igel"] }' }, headers: { 'X-Auth-Token' => token_value }
          json = JSON.parse(response.body)

          expect(response.status).to eq(422)
          expect(json['errors']['environment']).not_to be_empty
        end
      end
    end

    describe 'Chef' do
      context 'automation_admin' do
        before :each do
          @automation = FactoryGirl.create(:chef, chef_attributes: { test: 'test' }.to_json, repository_credentials: 'secret_password')
          @automation.attributes.delete('id')
          token['project']['id'] = project_id
          token['roles'].delete_if { |h| h['id'] == 'automation_role' }
          token['roles'] << { 'id' => 'automation_role', 'name' => 'automation_admin' }
          stub_authentication
        end

        it 'creates an automation' do
          post '/api/v1/automations/', params: @automation.attributes, headers: { 'X-Auth-Token' => token_value }
          expect(response.status).to eq(201)
          json = JSON.parse(response.body)
          expect(json['type']).to be == @automation.class.name
          expect(json['name']).to be == @automation.name
          expect(json['repository']).to be == @automation.repository
          expect(json['repository_revision']).to be == @automation.repository_revision
          expect(json['timeout']).to be == @automation.timeout
          expect(json['run_list']).to be == @automation.run_list
          expect(json['chef_attributes']).to be == @automation.chef_attributes
          expect(json['repository_credentials']).to eq(nil)
          expect(json['repository_authentication_enabled']).to eq(true)
        end

        it 'creates an automation with default false repository_authentication_enabled' do
          new_automation = FactoryGirl.create(:chef, chef_attributes: { test: 'test' }.to_json, repository_credentials: '')
          post '/api/v1/automations/', params: new_automation.attributes, headers: { 'X-Auth-Token' => token_value }
          expect(response.status).to eq(201)
          json = JSON.parse(response.body)
          expect(json['repository_credentials']).to eq(nil)
          expect(json['repository_authentication_enabled']).to eq(false)
        end

        it 'creates an automation in the right project' do
          post '/api/v1/automations', params: { type: 'Chef', name: 'prod_auto', repository: 'https://miau', run_list: ['test'] }, headers: { 'X-Auth-Token' => token_value }
          json = JSON.parse(response.body)
          expect(response.status).to eq(201)
          expect(json['type']).to be == 'Chef'
          expect(json['project_id']).to be == project_id
        end

        it 'return an authorization error 401 if token not valid' do
          post '/api/v1/automations/', params: { type: 'Chef', name: 'prod_auto', repository: 'https://miau', tags: '{}'.to_json }, headers: { 'X-Auth-Token' => 'token_no_valid' }
          expect(response.status).to eq(401)
        end

        it 'return status forbiden if token has no project' do
          # stub project id
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('current_user').as_null_object)
          post '/api/v1/automations/', params: { type: 'Chef', name: 'prod_auto', repository: 'https://miau', run_list: ['test'] }, headers: { 'X-Auth-Token' => token_value }
          expect(response.status).to eq(403)
        end
      end

      context 'automation_viewer' do
        before :each do
          token['roles'].delete_if { |h| h['id'] == 'automation_role' }
          token['roles'] << { 'id' => 'automation_role', 'name' => 'automation_viewer' }
          stub_authentication
        end

        it 'not allowed' do
          post '/api/v1/automations', params: { type: 'Chef', name: 'prod_auto', repository: 'https://miau', run_list: ['test'] }, headers: { 'X-Auth-Token' => token_value }
          expect(response.status).to eq(403)
        end
      end

      context 'other roles' do
        before :each do
          token['project']['id'] = project_id
          token['roles'].delete_if { |h| h['id'] == 'automation_role' }
          token['roles'] << { 'id' => 'automation_role', 'name' => 'compute_admin' }
          stub_authentication
        end

        it 'not allowed' do
          post '/api/v1/automations', params: { type: 'Chef', name: 'prod_auto', repository: 'https://miau', run_list: ['test'] }, headers: { 'X-Auth-Token' => token_value }
          expect(response.status).to eq(403)
        end
      end

      describe 'validations' do
        before :each do
          token['roles'].delete_if { |h| h['id'] == 'automation_role' }
          token['roles'] << { 'id' => 'automation_role', 'name' => 'automation_admin' }
          stub_authentication
        end

        it 'should be have generic fields present :type, :name' do
          post '/api/v1/automations', params: { type: 'Chef', repository: 'https://miau', run_list: ['test'] }, headers: { 'X-Auth-Token' => token_value }
          json = JSON.parse(response.body)
          expect(response.status).to eq(422)
          expect(json['errors']['name']).not_to be_empty

          post '/api/v1/automations', params: { name: 'prod_auto', repository: 'https://miau', run_list: ['test'] }, headers: { 'X-Auth-Token' => token_value }
          json = JSON.parse(response.body)
          expect(response.status).to eq(422)
          expect(json['errors']['type']).not_to be_empty
        end

        it 'should set the project from the given tocken' do
          post '/api/v1/automations', params: { type: 'Chef', name: 'prod_auto', repository: 'https://miau', run_list: ['test'] }, headers: { 'X-Auth-Token' => token_value }
          json = JSON.parse(response.body)
          expect(response.status).to eq(201)
          expect(json['project_id']).to eq(token['project']['id'])
        end

        it 'should have chef fields present :repository, :repository_revision, :run_list' do
          post '/api/v1/automations', params: { type: 'Chef', name: 'prod_auto', repository: 'https://miau' }, headers: { 'X-Auth-Token' => token_value }
          json = JSON.parse(response.body)
          expect(response.status).to eq(422)
          expect(json['errors']['run_list']).not_to be_empty

          post '/api/v1/automations', params: { type: 'Chef', name: 'prod_auto', run_list: ['test'] }, headers: { 'X-Auth-Token' => token_value }
          json = JSON.parse(response.body)
          expect(response.status).to eq(422)
          expect(json['errors']['repository']).not_to be_empty

          post '/api/v1/automations', params: { type: 'Chef', name: 'prod_auto', repository: 'https://miau', repository_revision: '', run_list: ['test'] }, headers: { 'X-Auth-Token' => token_value }
          json = JSON.parse(response.body)
          expect(response.status).to eq(422)
          expect(json['errors']['repository_revision']).not_to be_empty
        end

        it 'should check runlist to be a list' do
          post '/api/v1/automations', params: { type: 'Chef', name: 'prod_auto', repository: 'https://miau', run_list: 'test' }, headers: { 'X-Auth-Token' => token_value }
          json = JSON.parse(response.body)
          expect(response.status).to eq(422)
          expect(json['errors']['run_list']).not_to be_empty

          post '/api/v1/automations', params: { type: 'Chef', name: 'prod_auto', repository: 'https://miau', run_list: ['test'] }, headers: { 'X-Auth-Token' => token_value }
          expect(response.status).to eq(201)
        end

        it 'should check repository to have a valid url' do
          post '/api/v1/automations', params: { type: 'Chef', name: 'prod_auto', repository: 'cuack cuack', run_list: ['test'] }, headers: { 'X-Auth-Token' => token_value }
          json = JSON.parse(response.body)
          expect(response.status).to eq(422)
          expect(json['errors']['repository']).not_to be_empty
        end

        it 'should check chef_attributes for valid json' do
          post '/api/v1/automations', params: { type: 'Chef', name: 'prod_auto', repository: 'https://miau', run_list: ['test'], chef_attributes: 'test' }, headers: { 'X-Auth-Token' => token_value }
          json = JSON.parse(response.body)
          expect(response.status).to eq(422)
          expect(json['errors']['chef_attributes']).not_to be_empty

          post '/api/v1/automations', params: { type: 'Chef', name: 'prod_auto', repository: 'https://miau', run_list: ['test'], chef_attributes: '{ "docker-compos" : { "miau" : "bup" } }' }, headers: { 'X-Auth-Token' => token_value }
          json = JSON.parse(response.body)
          expect(response.status).to eq(201)
          expect(json['chef_attributes']).to eq('{ "docker-compos" : { "miau" : "bup" } }')
        end

        it 'should check chef_attributes for json string' do
          post '/api/v1/automations', params: { type: 'Chef', name: 'prod_auto', repository: 'https://miau', run_list: ['test'], chef_attributes: '{"docker-compos":{"miau":"bup"}}' }, headers: { 'X-Auth-Token' => token_value }
          json = JSON.parse(response.body)
          expect(response.status).to eq(201)
          expect(json['chef_attributes']).to eq({ 'docker-compos' => { 'miau' => 'bup' } }.to_json)
        end
      end
    end
  end

  describe 'update an automation' do
    describe 'Chef' do
      let(:chef) { FactoryGirl.create(:chef, project_id: project_id, chef_attributes: { 'test' => 'test' }) }

      context 'automation_admin' do
        before :each do
          token['project']['id'] = project_id
          token['roles'].delete_if { |h| h['id'] == 'automation_role' }
          token['roles'] << { 'id' => 'automation_role', 'name' => 'automation_admin' }
          stub_authentication
        end

        it 'updates chef_attributes' do
          res = { 'miau' => 'bup' }
          put "/api/v1/automations/#{chef.id}", params: { chef_attributes: res }, headers: { 'X-Auth-Token' => token_value }
          expect(response.status).to eq(200)

          chef.reload
          expect(chef.chef_attributes).to eq(res)
        end

        it 'keeps chef_attributes' do
          put "/api/v1/automations/#{chef.id}", params: { "name": 'nase' }, headers: { 'X-Auth-Token' => token_value }
          expect(response.status).to eq(200)

          chef.reload
          expect(chef.chef_attributes).to be == { 'test' => 'test' }
        end

        it 'updates repository_credentials' do
          put "/api/v1/automations/#{chef.id}", params: { "repository_credentials": 'new_passowrd' }, headers: { 'X-Auth-Token' => token_value }
          expect(response.status).to eq(200)

          chef.reload
          expect(chef.repository_credentials).to eq('new_passowrd')
          expect(chef.repository_authentication_enabled).to eq(true)
        end

        it 'set repository_authentication_enabled flag to false if repository_credentials removed' do
          put "/api/v1/automations/#{chef.id}", params: { "repository_credentials": '' }, headers: { 'X-Auth-Token' => token_value }
          expect(response.status).to eq(200)

          chef.reload
          expect(chef.repository_credentials).to eq('')
          expect(chef.repository_authentication_enabled).to eq(false)
        end

        it 'returns an authorization error 401 if token not valid' do
          put "/api/v1/automations/#{chef.id}", params: { chef_attributes: {} }, headers: { 'X-Auth-Token' => 'token_no_valid' }

          expect(response.status).to eq(401)
        end

        it 'return status forbiden if token has no project' do
          # stub project id
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('current_user').as_null_object)

          put "/api/v1/automations/#{chef.id}", params: { chef_attributes: {} }, headers: { 'X-Auth-Token' => token_value }

          # test for the 403 status-code
          expect(response.status).to eq(403)
        end
      end

      context 'automation_viewer' do
        before :each do
          token['project']['id'] = project_id
          token['roles'].delete_if { |h| h['id'] == 'automation_role' }
          token['roles'] << { 'id' => 'automation_role', 'name' => 'automation_viewer' }
          stub_authentication
        end

        it 'not allowed' do
          put "/api/v1/automations/#{chef.id}", params: { chef_attributes: {} }, headers: { 'X-Auth-Token' => token_value }
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
          put "/api/v1/automations/#{chef.id}", params: { chef_attributes: {} }, headers: { 'X-Auth-Token' => token_value }
          expect(response.status).to eq(403)
        end
      end
    end

    describe 'Script' do
      let(:script) { FactoryGirl.create(:script, project_id: project_id, environment: { 'TEST' => 'BLA' }) }

      context 'automation_admin' do
        before :each do
          token['project']['id'] = project_id
          token['roles'].delete_if { |h| h['id'] == 'automation_role' }
          token['roles'] << { 'id' => 'automation_role', 'name' => 'automation_admin' }
          stub_authentication
        end

        it 'update environment' do
          res = { 'name' => 'test' }
          put "/api/v1/automations/#{script.id}", params: { environment: res }, headers: { 'X-Auth-Token' => token_value }
          expect(response.status).to eq(200)

          script.reload
          expect(script.environment).to eq(res)
        end

        it 'keeps environment' do
          put "/api/v1/automations/#{script.id}", params: { "name": 'nase' }, headers: { 'X-Auth-Token' => token_value }
          expect(response.status).to eq(200)

          script.reload
          expect(script.environment).to be == { 'TEST' => 'BLA' }
        end

        it 'updates repository_credentials' do
          put "/api/v1/automations/#{script.id}", params: { "repository_credentials": 'new_passowrd' }, headers: { 'X-Auth-Token' => token_value }
          expect(response.status).to eq(200)

          script.reload
          expect(script.repository_credentials).to eq('new_passowrd')
          expect(script.repository_authentication_enabled).to eq(true)
        end

        it 'set repository_authentication_enabled flag to false if repository_credentials removed' do
          put "/api/v1/automations/#{script.id}", params: { "repository_credentials": '' }, headers: { 'X-Auth-Token' => token_value }
          expect(response.status).to eq(200)

          script.reload
          expect(script.repository_credentials).to eq('')
          expect(script.repository_authentication_enabled).to eq(false)
        end
      end

      context 'automation_viewer' do
        before :each do
          token['project']['id'] = project_id
          token['roles'].delete_if { |h| h['id'] == 'automation_role' }
          token['roles'] << { 'id' => 'automation_role', 'name' => 'automation_viewer' }
          stub_authentication
        end

        it 'not allowed' do
          put "/api/v1/automations/#{script.id}", params: { environment: {} }, headers: { 'X-Auth-Token' => token_value }
          expect(response.status).to eq(403)
        end
      end

      context 'other roles' do
        before :each do
          token['project']['id'] = project_id
          token['roles'].delete_if { |h| h['id'] == 'automation_role' }
          token['roles'] << { 'id' => 'automation_role', 'name' => 'compute_admin' }
          stub_authentication
        end

        it 'not allowed' do
          put "/api/v1/automations/#{script.id}", params: { environment: {} }, headers: { 'X-Auth-Token' => token_value }
          expect(response.status).to eq(403)
        end
      end
    end
  end

  describe 'delete an automation' do
    describe 'Chef' do
      let(:chef) { FactoryGirl.create(:chef, project_id: project_id) }
      context 'automation_admin' do
        before :each do
          token['project']['id'] = project_id
          token['roles'].delete_if { |h| h['id'] == 'automation_role' }
          token['roles'] << { 'id' => 'automation_role', 'name' => 'automation_admin' }
          stub_authentication
        end

        it 'succeed' do
          delete "/api/v1/automations/#{chef.id}", headers: { 'X-Auth-Token' => token_value }
          expect(response.status).to eq(204)
        end
      end

      context 'automation_viewer' do
        before :each do
          token['project']['id'] = project_id
          token['roles'].delete_if { |h| h['id'] == 'automation_role' }
          token['roles'] << { 'id' => 'automation_role', 'name' => 'automation_viewer' }
          stub_authentication
        end

        it 'not allowed' do
          delete "/api/v1/automations/#{chef.id}", headers: { 'X-Auth-Token' => token_value }
          expect(response.status).to eq(403)
        end
      end

      context 'other roles' do
        before :each do
          token['project']['id'] = project_id
          token['roles'].delete_if { |h| h['id'] == 'automation_role' }
          token['roles'] << { 'id' => 'automation_role', 'name' => 'compute_admin' }
          stub_authentication
        end

        it 'not allowed' do
          delete "/api/v1/automations/#{chef.id}", headers: { 'X-Auth-Token' => token_value }
          expect(response.status).to eq(403)
        end
      end
    end
  end

  describe 'execute an automation'
end
