FactoryGirl.define do
  factory :register, class: 'Register::Input' do
    transient do
      broker_id nil
    end
    group                 { FactoryGirl.create(:localpool) }
    direction             Register::Base.directions[:input]
    label                 Register::Base.labels[:consumption]
    pre_decimal_position  6
    post_decimal_position 2
    low_load_ability      false
    share_with_group      true
    share_publicly        false

    trait :real do
      before(:create) do |register, evaluator|
        register.meter = evaluator.meter || FactoryGirl.build(:meter, :real, group: register.group, registers: [ register ])
      end
    end

    trait :virtual do
      initialize_with { Register::Virtual.new }
      name            { 'Generic virtual register' }
      before(:create) do |register, evaluator|
        register.meter = evaluator.meter || FactoryGirl.build(:meter, :virtual, group: register.group, register: register)
      end
    end

    trait :virtual_input do
      virtual
      direction       Register::Base.directions[:input]
    end

    trait :virtual_output do
      virtual
      direction       Register::Base.directions[:output]
    end

    trait :input do
      real
      initialize_with { Register::Input.new }
      direction       Register::Base.directions[:input]
      name            { generate(:register_input_name) }
    end

    trait :output do
      real
      initialize_with { Register::Output.new }
      direction       Register::Base.directions[:output]
      name            { generate(:register_output_name) }
    end

    # This register is publicly connected. Only those have a metering point id
    trait :grid_connected do
      metering_point_id # uses sequence
    end

    trait :grid_input do
      input
      grid_connected
      label Register::Base.labels[:grid_consumption]
      name 'Netzanschluss Bezug'
    end

    trait :grid_output do
      output
      grid_connected
      label Register::Base.labels[:grid_feeding]
      name 'Netzanschluss Einspeisung'
    end

    trait :production_bhkw do
      output
      label Register::Base.labels[:production_chp]
      name 'Produktion BHKW'
    end

    trait :production_pv do
      output
      name 'Produktion PV'
      label Register::Base.labels[:production_pv]
    end
  end
end
