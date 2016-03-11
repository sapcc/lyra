FactoryGirl.define do

  # Script

  factory :script1, :class => 'Script' do
    name "my script automation"
    project_id "some_project_id"
    repository "http://some_git_url.git"
    path "/some_script"
    tags '{"pool":"red"}'.to_json
  end

  # Chef

  factory :chef1, :class => 'Chef' do
    name "my chef automation"
    project_id "some_project_id"
    repository "http://some_git_url.git"
    run_list ["recipe[cookbook]", "role[a-role]"]
    tags '{"pool":"red"}'.to_json
  end

end
