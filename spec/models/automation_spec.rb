require 'rails_helper'

RSpec.describe Automation, type: :model do

  describe 'script' do

    it 'should find by name' do
      script_automation = FactoryGirl.create(:script1)
      found = Automation.find_by_name script_automation.name, script_automation.project_id
      expect(script_automation.id).to be == found.id
    end

  end

end
