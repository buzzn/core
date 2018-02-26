FactoryGirl.define do
  factory :market_location do

    transient do
      contracts []
    end

    name '1.OG links vorne'
    group { FactoryGirl.create(:localpool) }

    trait :with_market_location_id do
      market_location_id { generate(:market_location_id) }
    end

    trait :with_contract do
      contracts { [create(:contract, :localpool_powertaker)] }
    end

    before(:create) do |market_location, evaluator|
      evaluator.contracts.each { |c| market_location.contracts << c }
    end
  end
end
