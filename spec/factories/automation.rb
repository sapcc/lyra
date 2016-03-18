FactoryGirl.define do

  # Script

  factory :script, :class => 'Script' do
    name "my script automation"
    project_id "some_project_id"
    repository "http://some_git_url.git"
    repository_revision "master"
    path "/some_script"
    tags '{"pool":"red"}'.to_json
  end

  # Chef

  factory :chef, :class => 'Chef' do
    name "my chef automation"
    project_id "some_project_id"
    repository "http://some_git_url.git"
    repository_revision "master"
    run_list ["recipe[cookbook]", "role[a-role]"]
    tags '{"pool":"red"}'.to_json
  end

end
