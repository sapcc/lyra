require 'rails_helper'

RSpec.describe Automation, type: :model do

  describe 'automation' do

    describe 'validation' do

      describe 'name' do

        it 'should not save automations with same name within the same project' do
          FactoryGirl.create(:script1)
          expect { FactoryGirl.create(:script1) }.to raise_error(ActiveRecord::RecordInvalid)

          FactoryGirl.create(:chef1)
          expect { FactoryGirl.create(:chef1) }.to raise_error(ActiveRecord::RecordInvalid)
        end

        it 'should set name length max to 256' do
          name_to_long = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec."
          expect( FactoryGirl.build(:script1,  name: name_to_long) ).not_to be_valid
          expect( FactoryGirl.build(:chef1,  name: name_to_long) ).not_to be_valid
        end

        it "should set name length min to 3" do
          name_to_short = "ab"
          expect( FactoryGirl.build(:script1,  name: name_to_short) ).not_to be_valid
          expect( FactoryGirl.build(:chef1,  name: name_to_short) ).not_to be_valid
        end

        it "should be present" do
          expect( FactoryGirl.build(:script1,  name: nil) ).not_to be_valid
        end

      end

      describe 'type' do

        it "should be present" do
          expect( FactoryGirl.build(:script1,  type: nil) ).not_to be_valid
        end

      end

      describe 'project_id' do

        it "should be present" do
          expect( FactoryGirl.build(:script1,  project_id: nil) ).not_to be_valid
        end

      end

      describe 'tags' do

        it 'should validate json' do
          expect( FactoryGirl.build(:script1, tags: 'no_valid_json'.to_json) ).not_to be_valid
          expect( FactoryGirl.build(:script1, tags: '{"this_is_json":"well_formated"}'.to_json ) ).to be_valid
        end

        it "should set the tags attribut to nil if an empty string is being set"

      end

    end

    describe 'all_from_project' do

      it 'success and sorted descending by updated_at' do
        teamA_script_automation = FactoryGirl.create(:script1, project_id: "TeamA")
        teamA_chef_automation = FactoryGirl.create(:chef1, project_id: "TeamA")
        teamB_script_automation = FactoryGirl.create(:script1, project_id: "TeamB")
        teamB_chef_automation = FactoryGirl.create(:chef1, project_id: "TeamB")
        automations = Automation.all_from_project("TeamB")
        expect(automations.count()).to be == 2
        expect(automations[0].id).to be == teamB_chef_automation.id
        expect(automations[1].id).to be == teamB_script_automation.id
      end

      it "should return an empty array if nothing found" do
        automations = Automation.all_from_project("non_existing_group")
        expect(automations.count()).to be == 0
      end

    end

    describe 'find by id' do

      it "success" do
        script_automation = FactoryGirl.create(:script1)
        found = Automation.find_by_id script_automation.id, script_automation.project_id
        expect(script_automation.id).to be == found.id

        chef_automation = FactoryGirl.create(:chef1)
        found = Automation.find_by_id chef_automation.id, chef_automation.project_id
        expect(chef_automation.id).to be == found.id
      end

      describe 'fail' do

        context 'failing silent' do

          it 'should return nil if not found' do
            found = Automation.find_by_id 'non_existing_id', 'non_exisiting_project'
            expect(found).to be == nil
          end

        end

        context 'throwing exceptions' do

          it "should raise an exception" do
            expect {  Automation.find_by_id! 'non_existing_id', 'non_exisiting_project' }.to raise_exception(ActiveRecord::RecordNotFound)
          end

        end

      end


    end

    describe 'find by name' do

      it 'success' do
        script_automation = FactoryGirl.create(:script1)
        found = Automation.find_by_name script_automation.name, script_automation.project_id
        expect(script_automation.id).to be == found.id

        chef_automation = FactoryGirl.create(:chef1)
        found = Automation.find_by_name chef_automation.name, chef_automation.project_id
        expect(chef_automation.id).to be == found.id
      end

      describe 'fail' do

        context 'failing silent' do

          it 'should return nil if not found' do
            found = Automation.find_by_name 'non_existing_name', 'non_exisiting_project'
            expect(found).to be == nil
          end

        end

        context 'throwing exceptions' do

          it "should raise an exception" do
            expect {  Automation.find_by_name! 'non_existing_name', 'non_exisiting_project' }.to raise_exception(ActiveRecord::RecordNotFound)
          end

        end

      end

    end

    describe 'type' do

      # it "should return the attribute" do
      #   script_automation = FactoryGirl.create(:script1)
      #   founds = Automation.all_from_project script_automation.project_id
      #   expect( founds.first.type).to be == 'Script'
      #
      #   binding.pry
      #
      #   chef_automation = FactoryGirl.create(:chef1)
      #   found = Automation.find_by_id chef_automation.id, chef_automation.project_id
      #   expect(found.type).to be == 'Chef'
      # end

    end

  end

  describe 'script' do

    it 'should validate the repository url' do
      expect( FactoryGirl.build(:script1, repository: "not_valid_url") ).not_to be_valid
      expect( FactoryGirl.build(:script1, repository: "http://valid_url") ).to be_valid
    end

  end

  describe 'chef' do

  end

end
