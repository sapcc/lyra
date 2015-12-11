require 'rails_helper'

RSpec.describe Automation, type: :model do

  describe 'automation' do

    it 'should not save automations with same name within the same project' do
      FactoryGirl.create(:script1)
      expect { FactoryGirl.create(:script1) }.to raise_error(ActiveRecord::RecordInvalid)

      FactoryGirl.create(:chef1)
      expect { FactoryGirl.create(:chef1) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should find by name' do
      script_automation = FactoryGirl.create(:script1)
      found = Automation.find_by_name script_automation.name, script_automation.project_id
      expect(script_automation.id).to be == found.id

      chef_automation = FactoryGirl.create(:chef1)
      found = Automation.find_by_name chef_automation.name, chef_automation.project_id
      expect(chef_automation.id).to be == found.id
    end

    it 'should set name length max to 256' do
      name_to_long = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec."
      expect( FactoryGirl.build(:script1,  name: name_to_long) ).not_to be_valid
      expect( FactoryGirl.build(:chef1,  name: name_to_long) ).not_to be_valid
    end

    it 'should validate json for tags' do
      expect( FactoryGirl.build(:script1, tags: "this is not json") ).not_to be_valid
      expect( FactoryGirl.build(:script1, tags: "{'this_is_json':'well_formated'}".to_json ) ).to be_valid
    end

  end

  describe 'script' do

    it 'should validate the git url as url' do
      expect( FactoryGirl.build(:script1, git_url: "not_valid_url") ).not_to be_valid
      expect( FactoryGirl.build(:script1, git_url: "http://valid_url") ).to be_valid
    end

  end

  describe 'chef' do

  end

end
