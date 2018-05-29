FactoryGirl.define do
  factory :market_location do

    transient do
      contracts []
      register nil
    end

    name '1.OG links vorne'
    group { FactoryGirl.create(:group, :localpool) }

    trait :with_market_location_id do
      market_location_id { generate(:market_location_id) }
    end

    trait :with_contract do
      after(:build) do |market_location|
        market_location.contracts = [create(:contract, :localpool_powertaker, localpool: market_location.group, market_location: market_location)]
      end
    end

    trait :consumption do
      after(:build) do |market_location, evaluator|
        create(:register, :consumption, market_location: market_location)
      end
    end

    after(:build) do |market_location, evaluator|
      register = evaluator.register
      market_location.register =
        if register.is_a?(Symbol)
          model = FactoryGirl.create(:meter, :real, group: market_location.group).registers.first
          model.send("#{register}!")
          model
        else
          register
        end
      if register.is_a?(Register::Base) && market_location.group != register.meter.group && register.meter.group
        market_location.group = register.meter.group
      end
      evaluator.contracts.each { |c| market_location.contracts << c }
    end
  end
end
