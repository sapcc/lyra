require 'rails_helper'
require_relative 'shared'

RSpec.describe 'Test Automations API' do
  describe 'Get all automation' do
    it 'return all automation' do
      script_automation = FactoryGirl.create(:script, project_id: project_id)
      chef_automation = FactoryGirl.create(:chef, project_id: project_id)
      FactoryGirl.create(:chef, project_id: 'some_other_project')

      # request
      get '/api/v1/automations', nil, 'X-Auth-Token' => token
      json = JSON.parse(response.body)

      # test for the 200 status-code
      expect(response).to be_success

      # check to make sure the right amount of messages are returned
      expect(json.length).to eq(2)
      expect(json[0]['id']).to eq(chef_automation.id)
      expect(json[1]['id']).to eq(script_automation.id)
    end

    it 'return an empty array if no automations found' do
      # request
      get '/api/v1/automations', nil, 'X-Auth-Token' => token
      json = JSON.parse(response.body)

      # test for the 200 status-code
      expect(response).to be_success

      # check to make sure the right amount of messages are returned
      expect(json.length).to eq(0)
    end

    it 'return an authorization error 401' do
      # request
      get '/api/v1/automations'

      # test for the 401 status-code
      expect(response.status).to eq(401)
    end

    it 'return status forbiden if token has no project' do
      # stub project id
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('current_user', project_id: nil))

      # request
      get '/api/v1/automations', nil, 'X-Auth-Token' => token

      # test for the 403 status-code
      expect(response.status).to eq(403)
    end

    describe 'pagination' do
      it_behaves_like 'model with pagination' do
        subject do
          (0..29).each do |_i|
            FactoryGirl.create(:script, project_id: project_id)
            FactoryGirl.create(:chef, project_id: project_id)
          end
          @path = '/api/v1/automations'
        end
      end
    end
  end

  describe 'show an automation' do
    context 'Script' do
      it 'return the automation' do
        script_automation = FactoryGirl.create(:script, name: 'production', project_id: project_id)

        # request
        get "/api/v1/automations/#{script_automation.id}", nil, 'X-Auth-Token' => token
        json = JSON.parse(response.body)

        # test for the 200 status-code
        expect(response).to be_success
        expect(json['id']).to be == script_automation.id
        expect(json['name']).to be == script_automation.name
        expect(json['type']).to be == script_automation.class.name
        expect(json['project_id']).to be == project_id
        expect(json['repository']).to be == script_automation.repository
      end
    end

    context 'Chef' do
      it 'return an automation'
    end

    it 'returns a 404 if automation not found' do
      # request
      get '/api/v1/automations/non_existing_automation', nil, 'X-Auth-Token' => token

      # test for the 404 status-code
      expect(response.status).to eq(404)
    end

    it 'return an authorization error 401' do
      name = 'production'
      script_automation = FactoryGirl.create(:script, name: name, project_id: project_id)

      # request
      get "/api/v1/automations/#{name}"

      # test for the 401 status-code
      expect(response.status).to eq(401)
    end

    it 'return status forbiden if taken has no project' do
      # stub project id
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('current_user', project_id: nil))

      # request
      get '/api/v1/automations/some_automation', nil, 'X-Auth-Token' => token

      # test for the 403 status-code
      expect(response.status).to eq(403)
    end
  end

  describe 'create an automation' do
    describe 'script' do
      it 'creates an automation in the right project' do
        # name already exists
        post '/api/v1/automations', { type: 'Script', name: 'prod_auto', path: 'script_path', repository: 'https://miau' }, 'X-Auth-Token' => token
        json = JSON.parse(response.body)

        expect(response.status).to eq(201)
        expect(json['type']).to be == 'Script'
        expect(json['project_id']).to be == project_id
      end

      describe 'validations' do
        it 'check name error show up' do
          name = 'production'
          FactoryGirl.create(:script, name: name, project_id: project_id)

          # name already exists
          post '/api/v1/automations/', { type: 'Script', name: name, project_id: project_id, path: 'script_path', repository: 'https://miau', tags: '{}'.to_json }, 'X-Auth-Token' => token
          json = JSON.parse(response.body)
          expect(response.status).to eq(422)
          expect(json['errors']['name']).not_to be_empty
        end

        it 'checks git url error shows up' do
          post '/api/v1/automations/', { type: 'Script', name: 'test_automation', project_id: project_id, path: 'script_path', repository: 'not_a_url', tags: '{}'.to_json }, 'X-Auth-Token' => token
          json = JSON.parse(response.body)

          expect(response.status).to eq(422)
          expect(json['errors']['repository']).not_to be_empty
        end

        it 'tags are filtered out' do
          post '/api/v1/automations/', { type: 'Script', name: 'test_automation', project_id: project_id, path: 'script_path', repository: 'http://uri', tags: 'not_json' }, 'X-Auth-Token' => token
          json = JSON.parse(response.body)

          expect(response.status).to eq(201)
          expect(json['tags']).to be_nil
        end

        it 'ignores invalid environment' do
          post '/api/v1/automations/', { type: 'Script', name: 'test_automation', project_id: project_id, path: 'script_path', repository: 'https://miau', environment: '{ hase: ["igel"] }' }.to_json, 'CONTENT_TYPE' => 'application/json', 'X-Auth-Token' => token
          json = JSON.parse(response.body)

          expect(response.status).to eq(422)
          expect(json['errors']['environment']).not_to be_empty
        end
      end
    end

    describe 'Chef' do
      it 'creates an automation in the right project'

      describe 'validations' do
        it 'should be have generic fields present :type, :name' do
          post '/api/v1/automations', { type: 'Chef', repository: 'https://miau', run_list: ['test'] }, 'X-Auth-Token' => token
          json = JSON.parse(response.body)
          expect(response.status).to eq(422)
          expect(json['errors']['name']).not_to be_empty

          post '/api/v1/automations', { name: 'prod_auto', repository: 'https://miau', run_list: ['test'] }, 'X-Auth-Token' => token
          json = JSON.parse(response.body)
          expect(response.status).to eq(422)
          expect(json['errors']['type']).not_to be_empty
        end

        it 'should set the project from the given tocken' do
          post '/api/v1/automations', { type: 'Chef', name: 'prod_auto', repository: 'https://miau', run_list: ['test'] }, 'X-Auth-Token' => token
          json = JSON.parse(response.body)
          expect(response.status).to eq(201)
          expect(json['project_id']).to eq(AuthenticationStub.test_token['project']['id'])
        end

        it 'should have chef fields present :repository, :repository_revision, :run_list' do
          post '/api/v1/automations', { type: 'Chef', name: 'prod_auto', repository: 'https://miau' }, 'X-Auth-Token' => token
          json = JSON.parse(response.body)
          expect(response.status).to eq(422)
          expect(json['errors']['run_list']).not_to be_empty

          post '/api/v1/automations', { type: 'Chef', name: 'prod_auto', run_list: ['test'] }, 'X-Auth-Token' => token
          json = JSON.parse(response.body)
          expect(response.status).to eq(422)
          expect(json['errors']['repository']).not_to be_empty

          post '/api/v1/automations', { type: 'Chef', name: 'prod_auto', repository: 'https://miau', repository_revision: '', run_list: ['test'] }, 'X-Auth-Token' => token
          json = JSON.parse(response.body)
          expect(response.status).to eq(422)
          expect(json['errors']['repository_revision']).not_to be_empty
        end

        it 'should check runlist to be a list' do
          post '/api/v1/automations', { type: 'Chef', name: 'prod_auto', repository: 'https://miau', run_list: 'test' }, 'X-Auth-Token' => token
          json = JSON.parse(response.body)
          expect(response.status).to eq(422)
          expect(json['errors']['run_list']).not_to be_empty

          post '/api/v1/automations', { type: 'Chef', name: 'prod_auto', repository: 'https://miau', run_list: ['test'] }, 'X-Auth-Token' => token
          expect(response.status).to eq(201)
        end

        it 'should check repository to have a valid url' do
          post '/api/v1/automations', { type: 'Chef', name: 'prod_auto', repository: 'cuack cuack', run_list: ['test'] }, 'X-Auth-Token' => token
          json = JSON.parse(response.body)
          expect(response.status).to eq(422)
          expect(json['errors']['repository']).not_to be_empty
        end

        it 'should check chef_attributes for valid json' do
          post '/api/v1/automations', { type: 'Chef', name: 'prod_auto', repository: 'https://miau', run_list: ['test'], chef_attributes: 'test' }, 'X-Auth-Token' => token
          json = JSON.parse(response.body)
          expect(response.status).to eq(422)
          expect(json['errors']['chef_attributes']).not_to be_empty

          post '/api/v1/automations', { type: 'Chef', name: 'prod_auto', repository: 'https://miau', run_list: ['test'], chef_attributes: 124 }, 'X-Auth-Token' => token
          json = JSON.parse(response.body)
          expect(response.status).to eq(422)
          expect(json['errors']['chef_attributes']).not_to be_empty

          post '/api/v1/automations', { type: 'Chef', name: 'prod_auto', repository: 'https://miau', run_list: ['test'], chef_attributes: { 'docker-compos' => { 'miau' => 'bup' } } }, 'X-Auth-Token' => token
          json = JSON.parse(response.body)
          expect(response.status).to eq(201)
          expect(json['chef_attributes']).to eq('docker-compos' => { 'miau' => 'bup' })
        end
      end
    end

    it 'return an authorization error 401' do
      post '/api/v1/automations/', { type: 'Chef', name: 'prod_auto', repository: 'https://miau', tags: '{}'.to_json }, 'X-Auth-Token' => 'not_valid_token'

      expect(response.status).to eq(401)
    end

    it 'return status forbiden if token has no project' do
      # stub project id
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(double('current_user', project_id: nil))
      post '/api/v1/automations/', { type: 'Chef', name: 'prod_auto', repository: 'https://miau', tags: '{}'.to_json }, 'X-Auth-Token' => token

      # test for the 403 status-code
      expect(response.status).to eq(403)
    end

    it 'succeeds' do
      automation = FactoryGirl.create(:chef, chef_attributes: { test: 'test' }.to_json)
      automation_attr = automation.attributes
      automation_attr.delete('id')
      post '/api/v1/automations/', automation_attr, 'X-Auth-Token' => token
      expect(response.status).to eq(201)
      json = JSON.parse(response.body)

      expect(json['type']).to be == automation.class.name
      expect(json['name']).to be == automation.name
      expect(json['repository']).to be == automation.repository
      expect(json['repository_revision']).to be == automation.repository_revision
      expect(json['timeout']).to be == automation.timeout
      expect(json['run_list']).to be == automation.run_list
      expect(json['chef_attributes']).to be == automation.chef_attributes
      expect(json['debug'].to_s).to be == automation.debug.to_s
      expect(json['chef_version']).to be == automation.chef_version
    end
  end

  describe 'update an automation' do
    let(:chef) { FactoryGirl.create(:chef, project_id: project_id, chef_attributes: { 'test' => 'test' }) }
    let(:script) { FactoryGirl.create(:script, project_id: project_id, path: '/bla', arguments: ['1'], environment: { 'TEST' => 'BLA' }) }

    it 'deletes chef_attributes' do
      put "/api/v1/automations/#{chef.id}", { chef_attributes: {} }.to_json, 'CONTENT_TYPE' => 'application/json', 'X-Auth-Token' => token
      expect(response.status).to eq(200)

      chef.reload
      expect(chef.chef_attributes).to be_empty
    end

    it 'keeps chef_attributes' do
      put "/api/v1/automations/#{chef.id}", { "name": 'nase' }.to_json, 'CONTENT_TYPE' => 'application/json', 'X-Auth-Token' => token
      expect(response.status).to eq(200)

      script.reload
      expect(chef.chef_attributes).to be == { 'test' => 'test' }
    end

    it 'deletes arguments' do
      put "/api/v1/automations/#{script.id}", { "hase": 'nase', "arguments": [] }.to_json, 'CONTENT_TYPE' => 'application/json', 'X-Auth-Token' => token
      expect(response.status).to eq(200)

      script.reload
      expect(script.arguments).to be_empty
    end

    it 'keeps arguments' do
      put "/api/v1/automations/#{script.id}", { "name": 'nase' }.to_json, 'CONTENT_TYPE' => 'application/json', 'X-Auth-Token' => token
      expect(response.status).to eq(200)

      script.reload
      expect(script.arguments).to be == ['1']
    end

    it 'deletes environment' do
      put "/api/v1/automations/#{script.id}", { "environment": {} }.to_json, 'CONTENT_TYPE' => 'application/json', 'X-Auth-Token' => token
      expect(response.status).to eq(200)

      script.reload
      expect(script.environment).to be_empty
    end

    it 'keeps environment' do
      put "/api/v1/automations/#{script.id}", {}.to_json, 'CONTENT_TYPE' => 'application/json', 'X-Auth-Token' => token
      expect(response.status).to eq(200)

      script.reload
      expect(script.environment).to be == { 'TEST' => 'BLA' }
    end
  end

  describe 'delete an automation' do
    it 'return status forbiden if taken has no project'
  end
end
