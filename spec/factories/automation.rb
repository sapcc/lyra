FactoryGirl.define do

  # Script

  factory :script1, :class => 'Script' do
    name "my script automation"
    project_id "some_project_id"
    git_url "http://some_git_url"
    tags { { pool: "red" }.to_json }
  end

  # Chef

  factory :chef1, :class => 'Chef' do
    name "my chef automation"
    project_id "some_project_id"
    tags { { pool: "red" }.to_json }
  end

end