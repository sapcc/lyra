require 'rails_helper'
require 'git_url'
RSpec.describe "GitURL" do

  it 'parses https urls' do
    u = GitURL.parse 'https://github.com/bla/fasel.git'
    expect(u).to be_an(URI::HTTPS)
    expect(u.scheme).to eq("https")
  end

  it 'parses scp like urls' do
    u = GitURL.parse 'git@github.com:bla/fasel.git'
    expect(u.to_s).to eq("ssh://git@github.com/bla/fasel.git")
    u = GitURL.parse 'github.com:bla/fasel.git'
    expect(u.to_s).to eq("ssh://github.com/bla/fasel.git")
  end

end
