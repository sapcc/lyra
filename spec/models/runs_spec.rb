require 'rails_helper'

RSpec.describe Run, type: :model do

  let(:run) { FactoryGirl.create(:run) }

  it "has a valid factory" do
    expect(run).to be_valid
  end

  it "appends logs" do

    run.log "a string"
    run.log "second string"
    run.reload
    expect(run.log).to eq("a stringsecond string")
    
  end

end
