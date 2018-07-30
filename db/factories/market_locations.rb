FactoryGirl.define do
  factory :market_location do

    transient do
      contracts []
      register nil
    end

    trait :consumption_common do
      after(:build) do |market_location, evaluator|
        create(:register, :real, :consumption_common, market_location: market_location)
      end
    end

    trait :consumption do
      after(:build) do |market_location, evaluator|
        create(:register, :real, :consumption, market_location: market_location)
      end
    end

    trait :production_water do
      after(:build) do |market_location, evaluator|
        create(:register, :real, :production_water, market_location: market_location)
      end
    end

    after(:build) do |market_location, evaluator|
      register = evaluator.register
      market_location.register = register
      if register.is_a?(Register::Base) && market_location.group != register.meter.group && register.meter.group
        market_location.group = register.meter.group
      end
      evaluator.contracts.each { |c| market_location.contracts << c }
    end
  end
end
