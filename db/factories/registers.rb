FactoryGirl.define do
  factory :register, class: 'Register::Input' do
    group                 { FactoryGirl.create(:localpool) }
    # Can't save the associated meter yet. It validates it has a register, and then we run into a chicken-and-egg
    # situation (each record requires the other to be persisted to be valid).
    meter                 { FactoryGirl.build(:meter_real) }
    direction             Register::Base.directions[:input]
    label                 Register::Base.labels[:consumption]
    pre_decimal_position  6
    post_decimal_position 2
    low_load_ability      false
    share_with_group      true
    share_publicly        false

    trait :input do
      initialize_with { Register::Input.new } # a slight hack to define a trait of contract, but use a different subclass
      name            { generate(:register_input_name) }
    end

    trait :output do
      initialize_with { Register::Output.new } # a slight hack to define a trait of contract, but use a different subclass
      name            { generate(:register_output_name) }
    end

    trait :grid_connected do
      metering_point_id # uses sequence
    end
  end
end
