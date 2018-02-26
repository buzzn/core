FactoryGirl.define do
  factory :market_location do
    name '1.OG links vorne'
    group { FactoryGirl.create(:localpool) }
  end

  trait :with_market_location_id do
    market_location_id { generate(:market_location_id) }
  end

  trait :with_contract do
    contracts { [create(:contract, :localpool_powertaker)] }
  end
end
