require 'rails_helper'

RSpec.describe "Test Automations API" do

  describe "Get all automation " do

    it 'return all automation from a given project' do
      script_atuomation = FactoryGirl.create(:script1)
      chef_atuomation = FactoryGirl.create(:chef1)

      get '/api/v1/automations'

      json = JSON.parse(response.body)

      # test for the 200 status-code
      expect(response).to be_success

      # check to make sure the right amount of messages are returned
      expect(json.length).to eq(2)
      expect(json[0]['id']).to eq(script_atuomation.id)
      expect(json[1]['id']).to eq(chef_atuomation.id)
    end

  end

end