FactoryGirl.define do
  factory :register_input, class: 'Register::Input' do
    group                 { FactoryGirl.create(:localpool) }
    # Can't save the associated meter yet. It validates it has a register, and then we run into a chicken-and-egg
    # situation (each record requires the other to be persisted to be valid).
    meter                 { FactoryGirl.build(:meter_real) }
    name                  { generate(:register_input_name) }
    direction             Register::Base.directions[:input]
    label                 Register::Base.labels[:consumption]
    metering_point_id # uses sequence
    pre_decimal_position  6
    post_decimal_position 2
    low_load_ability      false
    share_with_group      true
    share_publicly        false
  end
end