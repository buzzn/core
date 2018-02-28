FactoryGirl.define do
  factory :market_location do

    transient do
      contracts []
      register nil
    end

    name '1.OG links vorne'
    group { FactoryGirl.create(:localpool) }

    trait :with_market_location_id do
      market_location_id { generate(:market_location_id) }
    end

    trait :with_contract do
      contracts { [create(:contract, :localpool_powertaker)] }
    end

    after(:build) do |market_location, evaluator|
      market_location.register = if evaluator.register.is_a?(Symbol)
                                   FactoryGirl.create(:register, :real, evaluator.register)
                                 else
                                   market_location.register = evaluator.register
                                 end
      evaluator.contracts.each { |c| market_location.contracts << c }
    end
  end
end
