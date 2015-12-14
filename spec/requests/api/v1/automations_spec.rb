require 'rails_helper'

RSpec.describe "Test Automations API" do

  let(:token) { ENV['AUTOMATION_AUTH_TOKEN'] }
  let(:project) { ENV['AUTOMATION_AUTH_PROJECT'] }

  describe "Get all automation " do

    it 'return all automation' do
      script_atuomation = FactoryGirl.create(:script1, project_id: project)
      chef_atuomation = FactoryGirl.create(:chef1, project_id: project)
      FactoryGirl.create(:chef1, project_id: "some_other_project")

      # request
      get '/api/v1/automations', nil, {'X-Auth-Token' => token}
      json = JSON.parse(response.body)

      # test for the 200 status-code
      expect(response).to be_success

      # check to make sure the right amount of messages are returned
      expect(json.length).to eq(2)
      expect(json[0]['id']).to eq(chef_atuomation.id)
      expect(json[1]['id']).to eq(script_atuomation.id)
    end

    it 'return an empty array if no automations found' do
      # request
      get '/api/v1/automations', nil, {'X-Auth-Token' => token}
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

  end

  describe 'show an automation' do

    it 'return the automation' do
      name = 'production'
      script_atuomation = FactoryGirl.create(:script1, name: name, project_id: project)

      # request
      get "/api/v1/automations/#{name}", nil, {'X-Auth-Token' => token}
      json = JSON.parse(response.body)

      # test for the 200 status-code
      expect(response).to be_success
      expect(json['id']).to be == script_atuomation.id
      expect(json['name']).to be == script_atuomation.name
    end

    it 'returns a 404 if automation not found' do
      # request
      get "/api/v1/automations/non_existing_automation", nil, {'X-Auth-Token' => token}

      # test for the 404 status-code
      expect(response.status).to eq(404)
    end

    it 'return an authorization error 401' do
      name = 'production'
      script_atuomation = FactoryGirl.create(:script1, name: name, project_id: project)

      # request
      get "/api/v1/automations/#{name}"

      # test for the 401 status-code
      expect(response.status).to eq(401)
    end

  end

  describe 'create an automation' do

    context 'script' do

      it 'creates an automation'

      it 'returns validation errors' do
        
      end

    end

    it 'return an authorization error 401'

  end

  describe 'update an automation'

  describe 'delete an automation'

end