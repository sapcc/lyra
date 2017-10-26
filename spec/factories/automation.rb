FactoryGirl.define do

  # Script

  factory :script, :class => 'Script' do
    sequence(:name) {|n| "script_automation_#{n}"}
    project_id "some_project_id"
    repository "http://some_git_url.git"
    repository_revision "master"
    timeout 3600
    path "/some_script"
  end

  # Chef

  factory :chef, :class => 'Chef' do
    sequence(:name) {|n| "chef_automation_#{n}"}
    project_id "some_project_id"
    repository "http://some_git_url.git"
    repository_revision "master"
    timeout 3600
    run_list ["recipe[cookbook]", "role[a-role]"]
    chef_version "12.3.0"
    debug true
  end

end
