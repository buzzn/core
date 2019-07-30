FactoryGirl.define do
  factory :register, class: 'Register::Input' do
    transient do
      readings nil
    end

    direction             Register::Base.directions[:input]
    label                 Register::Base.labels[:consumption]
    share_with_group      true
    share_publicly        false

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
      direction Register::Base.directions[:input]
    end

    trait :virtual_output do
      virtual
      direction Register::Base.directions[:output]
    end

    trait :input do
      real
      initialize_with { Register::Input.new }
      direction       Register::Base.directions[:input]
    end

    trait :output do
      real
      initialize_with { Register::Output.new }
      label           Register::Base.labels[:production_pv]
      direction       Register::Base.directions[:output]
    end

    trait :with_market_location do
      before(:create) do |register, evaluator|
        create(:market_location, register: register)
      end
    end

    # This register is publicly connected. Only those have a metering point id
    trait :grid_connected do
      metering_point_id # uses sequence
    end

    trait :grid_input do
      input
      grid_connected
      label Register::Base.labels[:grid_consumption]
    end

    trait :grid_output do
      output
      grid_connected
      label Register::Base.labels[:grid_feeding]
    end

    trait :production_bhkw do
      output
      label Register::Base.labels[:production_chp]
    end

    trait :production_pv do
      output
      label Register::Base.labels[:production_pv]
    end

    trait :production_water do
      output
      label Register::Base.labels[:production_water]
    end

    trait :consumption do
      input
      label Register::Base.labels[:consumption]
    end

    trait :consumption_common do
      input
      label Register::Base.labels[:consumption_common]
    end
  end
end
