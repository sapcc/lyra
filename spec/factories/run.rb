FactoryGirl.define do

  factory :run do
    state "preparing"
    owner( {id: "some-owner-id", name:"some-owner-name", domain_id: "some-domain-id", domain_name: "some-domain-name"}.to_json)
    selector "bla=fasel"
    association :automation, factory: :chef
  end
end
