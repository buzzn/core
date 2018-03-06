FactoryGirl.define do
  factory :billing_brick do
    billing { FactoryGirl.build(:billing) }

    after(:build) do |billing_brick, evaluator|
      if evaluator.billing
        billing_brick.begin_date = evaluator.billing.begin_date
        billing_brick.end_date = evaluator.billing.end_date
      else
        billing_brick.begin_date = Date.new(2017, 1, 1)
        billing_brick.end_date   = Date.new(2017, 12, 31)
      end
    end

    trait :with_readings do
      begin_reading { FactoryGirl.build(:reading, raw_value: 100_000) }
      end_reading   { FactoryGirl.build(:reading, raw_value: 200_000) }
    end
  end
end
