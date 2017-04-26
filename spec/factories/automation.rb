FactoryGirl.define do

  # Script

  factory :script, :class => 'Script' do
    sequence(:name) {|n| "script_automation_#{n}"}
    project_id "some_project_id"
    repository "http://some_git_url.git"
    repository_revision "master"
    timeout 3600
    path "/some_script"
    tags '{"pool":"red"}'.to_json
  end

  # Chef

  factory :chef, :class => 'Chef' do
    sequence(:name) {|n| "chef_automation_#{n}"}
    project_id "some_project_id"
    repository "http://some_git_url.git"
    repository_revision "master"
    timeout 3600
    run_list ["recipe[cookbook]", "role[a-role]"]
    tags '{"pool":"red"}'.to_json
    chef_version "12.3.0"
  end

end
