FactoryGirl.define do

  factory :run do
    state "preparing"
    owner "some-owner"
    selector "bla=fasel"
    association :automation, factory: :chef
  end
end
