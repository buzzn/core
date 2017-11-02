FactoryGirl.define do
  factory :register, class: 'Register::Input' do
    group                 { FactoryGirl.create(:localpool) }
    # Can't save the associated meter yet. It validates it has a register, and then we run into a chicken-and-egg
    # situation (each record requires the other to be persisted to be valid).
    meter                 { FactoryGirl.build(:meter, :real, group: group, registers: []) }
    direction             Register::Base.directions[:input]
    label                 Register::Base.labels[:consumption]
    pre_decimal_position  6
    post_decimal_position 2
    low_load_ability      false
    share_with_group      true
    share_publicly        false

    before(:create) do |register|
      # make sure register and meter are wired up correctly
      register.meter.registers << register
    end

    trait :virtual do
      initialize_with { Register::Virtual.new } # a slight hack to define a trait of contract, but use a different subclass
      name            { 'Generic virtual register' }
      meter           { FactoryGirl.build(:meter_virtual, group: group, registers: []) }
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
      initialize_with { Register::Input.new } # a slight hack to define a trait of contract, but use a different subclass
      direction       Register::Base.directions[:input]
      name            { generate(:register_input_name) }
    end

    trait :output do
      initialize_with { Register::Output.new } # a slight hack to define a trait of contract, but use a different subclass
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
