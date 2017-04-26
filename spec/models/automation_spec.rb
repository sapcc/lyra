require 'rails_helper'

RSpec.describe Automation, type: :model do

  describe 'automation' do

    describe 'validation' do

      describe 'name' do

        it 'should not save automations with same name within the same project' do
          FactoryGirl.create(:script, name: 'script')
          expect { FactoryGirl.create(:script, name: 'script') }.to raise_error(ActiveRecord::RecordInvalid)

          FactoryGirl.create(:chef, name: 'chef')
          expect { FactoryGirl.create(:chef, name: 'chef') }.to raise_error(ActiveRecord::RecordInvalid)
        end

        it 'should set name length max to 256' do
          name_to_long = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec."
          expect( FactoryGirl.build(:script,  name: name_to_long) ).not_to be_valid
          expect( FactoryGirl.build(:chef,  name: name_to_long) ).not_to be_valid
        end

        it "should set name length min to 3" do
          name_to_short = "ab"
          expect( FactoryGirl.build(:script,  name: name_to_short) ).not_to be_valid
          expect( FactoryGirl.build(:chef,  name: name_to_short) ).not_to be_valid
        end

        it "should be present" do
          expect( FactoryGirl.build(:script,  name: nil) ).not_to be_valid
        end

      end

      describe 'automation' do

        it "should just allow timeout in range fron 1..86400 seconds" do
          timeout_small = 0
          timeout_big = 90000
          timeout_good = 3700
          expect( FactoryGirl.build(:script,  timeout: timeout_small) ).not_to be_valid
          expect( FactoryGirl.build(:chef,  timeout: timeout_small) ).not_to be_valid
          expect( FactoryGirl.build(:script,  timeout: timeout_big) ).not_to be_valid
          expect( FactoryGirl.build(:chef,  timeout: timeout_big) ).not_to be_valid
          expect( FactoryGirl.build(:script,  timeout: timeout_good) ).to be_valid
          expect( FactoryGirl.build(:chef,  timeout: timeout_good) ).to be_valid
        end

      end

      describe 'type' do

        it "should be present" do
          expect( FactoryGirl.build(:script,  type: nil) ).not_to be_valid
        end

      end

      describe 'project_id' do

        it "should be present" do
          expect( FactoryGirl.build(:script,  project_id: nil) ).not_to be_valid
        end

      end

      describe 'repository_revision' do
        it "should default to master" do
          # FactoryGirl can't be used here: http://stackoverflow.com/a/5931646
          expect( Chef.new.repository_revision ).to eq("master")
        end
      end

      describe 'tags' do

        it 'should validate json' do
          expect( FactoryGirl.build(:script, tags: 'no_valid_json'.to_json) ).not_to be_valid
          expect( FactoryGirl.build(:script, tags: '{"this_is_json":"well_formated"}'.to_json ) ).to be_valid

          #Test
          automation = FactoryGirl.create(:chef)
          expect(Automation.find(automation.id)).to be_valid
        end

        it "nullifies an empty string" do
          expect( FactoryGirl.create(:script, tags: "").tags ).to be_nil
        end

        pending "validate that tags are a simple key/value pairs"

      end

    end

    describe 'by_project' do

      it 'success and sorted descending by updated_at' do
        teamA_script_automation = FactoryGirl.create(:script, project_id: "TeamA")
        teamA_chef_automation = FactoryGirl.create(:chef, project_id: "TeamA")
        teamB_script_automation = FactoryGirl.create(:script, project_id: "TeamB")
        teamB_chef_automation = FactoryGirl.create(:chef, project_id: "TeamB")
        automations = Automation.by_project("TeamB")
        expect(automations.count()).to be == 2
        expect(automations[0].id).to be == teamB_chef_automation.id
        expect(automations[1].id).to be == teamB_script_automation.id
      end

      it "should return an empty array if nothing found" do
        automations = Automation.by_project("non_existing_group")
        expect(automations.count()).to be == 0
      end

    end

    describe 'type' do

      # it "should return the attribute" do
      #   script_automation = FactoryGirl.create(:script)
      #   founds = Automation.all_from_project script_automation.project_id
      #   expect( founds.first.type).to be == 'Script'
      #
      #   binding.pry
      #
      #   chef_automation = FactoryGirl.create(:chef)
      #   found = Automation.find_by_id chef_automation.id, chef_automation.project_id
      #   expect(found.type).to be == 'Chef'
      # end

    end

  end

  describe 'script' do

    it 'should validate the repository url' do
      expect( FactoryGirl.build(:script, repository: "not_valid_url") ).not_to be_valid
      expect( FactoryGirl.build(:script, repository: "http://valid_url") ).to be_valid
    end

  end

  describe 'chef' do

  end

end
