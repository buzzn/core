FactoryGirl.define do
  factory :register, class: 'Register::Real' do
    transient do
      readings nil
    end

    meta { FactoryGirl.build(:meta) }

    after(:create) do |register, transients|
      register.readings = transients.readings if transients.readings
    end

    trait :real do
      before(:create) do |register, evaluator|
        register.meter = evaluator.meter || FactoryGirl.build(:meter, :real, registers: [])
        register.meter.registers << register
      end
    end

    trait :substitute do
      initialize_with { Register::Substitute.new }
      before(:create) do |register, evaluator|
        register.meter = evaluator.meter || FactoryGirl.build(:meter, :virtual, registers: [])
        register.meter.registers << register
      end
    end

    trait :virtual do
      initialize_with { Register::Virtual.new }
      before(:create) do |register, evaluator|
        register.meter = evaluator.meter || FactoryGirl.build(:meter, :virtual, registers: [])
        register.meter.registers << register
      end
    end

    trait :virtual_input do
      virtual
    end

    trait :virtual_output do
      virtual
    end

    trait :input do
      real
      initialize_with { Register::Real.new }
    end

    trait :output do
      real
      initialize_with { Register::Real.new }
    end

    trait :with_market_location do
      before(:create) do |register, evaluator|
        create(:market_location, register: register)
      end
    end

    [:grid_consumption, :grid_feeding,
     :production_bhkw, :production_pv, :production_water, :production_wind,
     :consumption, :consumption_common
    ].each do |name|
      trait name do
        meta { FactoryGirl.build(:meta, name) }
      end
    end
  end
end
