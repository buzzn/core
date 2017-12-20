FactoryGirl.define do
  factory :broker, class: 'Broker::Base' do
    type               "Broker::Base"

    trait :discovergy do
      initialize_with { Broker::Discovergy.new }
      type            "Broker::Discovergy"
    end
  end
end
