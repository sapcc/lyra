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

    context 'Script' do

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
        expect(json['type']).to be == script_atuomation.class.name
        expect(json['project_id']).to be == project
        expect(json['git_url']).to be == script_atuomation.git_url
        expect(json['tags']).to be == script_atuomation.tags
      end

    end

    context 'Chef' do

      it "return an automation"

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

    describe 'script' do

      it 'creates an automation in the right project' do

        # name already exists
        post "/api/v1/automations/", {automation: {type: "Script", name: 'prod_auto', git_url: 'https://miau', tags:'{}'.to_json}}, {'X-Auth-Token' => token}
        json = JSON.parse(response.body)

        expect(response.status).to eq(201)
        expect(json['type']).to be == 'Script'
      end

      describe 'validations' do

        it 'check name error show up' do
          name = "production"
          FactoryGirl.create(:script1, name: name, project_id: project)

          # name already exists
          post "/api/v1/automations/", {automation: {type: "Script", name: name, project_id: project, git_url: 'https://miau', tags:'{}'.to_json}}, {'X-Auth-Token' => token}
          json = JSON.parse(response.body)

          expect(response.status).to eq(422)
          expect(json['name']).not_to be_empty
        end

        it 'checks git url error shows up'

        it 'checks tags are valid error shows up'

      end

    end

    it 'return an authorization error 401'

  end

  describe 'update an automation'

  describe 'delete an automation'

end