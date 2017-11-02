FactoryGirl.define do
  factory :meter do
    transient do
      registers nil
    end

    group                        { FactoryGirl.create(:localpool) }
    direction_number             Meter::Real.direction_numbers[:one_way_meter]
    section                      Meter::Real.sections[:electricity]

    before(:create) do |meter, evaluator|
      # registers
      meter.registers = if evaluator.registers.present?
        evaluator.registers
      else
        register_factory = meter.is_a?(Meter::Virtual) ? :virtual_input : :input
        [ FactoryGirl.build(:register, register_factory, meter: meter, group: meter.group) ]
      end
      # address
      meter.address = if meter.group.address
        meter.group.address.dup # use from group when present
      else
        FactoryGirl.create(:address)
      end
    end

    trait :one_way do
      direction_number           Meter::Real.direction_numbers[:one_way_meter]
      converter_constant         1
    end

    trait :two_way do
      direction_number           Meter::Real.direction_numbers[:two_way_meter]
      converter_constant         40
    end

    trait :real do
      initialize_with              { Meter::Real.new }
      manufacturer_name            Meter::Real.manufacturer_names[:easy_meter]
      product_serialnumber         { generate(:meter_serial_number) }
      product_name                 "Q3D"
      calibrated_until             Date.parse("2027-10-13")
      converter_constant           1
      ownership                    Meter::Real.ownerships[:buzzn]
      build_year                   2015
      sent_data_dso                Date.parse("2016-09-17")
      # edifact data
      edifact_metering_type        Meter::Real.edifact_metering_types[:digital_household_meter]
      edifact_meter_size           Meter::Real.edifact_meter_sizes[:edl40]
      edifact_measurement_method   Meter::Real.edifact_measurement_methods[:remote]
      edifact_mounting_method      Meter::Real.edifact_mounting_methods[:three_point_mounting]
      edifact_voltage_level        Meter::Real.edifact_voltage_levels[:low_level]
      edifact_cycle_interval       Meter::Real.edifact_cycle_intervals[:yearly]
      edifact_tariff               Meter::Real.edifact_tariffs[:single_tariff]
      edifact_data_logging         Meter::Real.edifact_data_loggings[:electronic]
    end

    trait :virtual do
      initialize_with { Meter::Virtual.new }
      product_name                 "buzzn virtual meter"
    end
  end
end
