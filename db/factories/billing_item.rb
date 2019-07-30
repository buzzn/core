FactoryGirl.define do
  factory :billing_item do
    billing             { FactoryGirl.build(:billing) }
    contract_type       'power_taker'

    after(:build) do |billing_item, evaluator|
      unless billing_item.begin_date && billing_item.end_date
        if evaluator.billing
          billing_item.begin_date = evaluator.billing.begin_date
          billing_item.end_date = evaluator.billing.end_date
        else
          billing_item.begin_date = Date.new(2017, 1, 1)
          billing_item.end_date   = Date.new(2017, 12, 31)
        end
      end
      if evaluator.billing&.contract
        evaluator.register = evaluator.billing.contract.market_location.register
      end
    end

    trait :with_readings do
      begin_reading { FactoryGirl.build(:reading, raw_value: 100_000) }
      end_reading   { FactoryGirl.build(:reading, raw_value: 200_000) }
    end
  end
end
