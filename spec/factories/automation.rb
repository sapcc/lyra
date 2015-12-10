FactoryGirl.define do

  factory :script1, :class => 'Script' do
    name "my automation"
    project_id "some_project_id"
    git_url "http://some_git_url"
    tags { { pool: "red" }.to_json }
  end

end