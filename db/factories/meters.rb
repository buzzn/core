FactoryGirl.define do
  factory :meter do
    transient do
      registers nil
      register_direction :input
    end

    group { FactoryGirl.create(:localpool) }

    before(:create) do |meter, evaluator|
      case meter
      when Meter::Virtual
        # register
        if evaluator.registers.present?
          meter.register = evaluator.registers.first
        else
          meter.register = FactoryGirl.build(:register, :virtual_input, meter: meter)
        end
      when Meter::Real
        # registers
        if evaluator.registers.present?
          meter.registers = evaluator.registers
        else
          meter.registers = [FactoryGirl.build(:register, evaluator.register_direction, meter: meter)]
        end
      end
    end

    trait :with_broker do
      broker                     { Broker::Discovergy.new }
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
      manufacturer_description     { generate(:meter_manufacturer_description) }
      location_description         { generate(:meter_location_description) }
      product_serialnumber         { generate(:meter_serial_number) }
      product_name                 'Q3D'
      direction_number             Meter::Real.direction_numbers[:one_way_meter]
      calibrated_until             Date.parse('2027-10-13')
      converter_constant           1
      ownership                    Meter::Real.ownerships[:buzzn]
      build_year                   2015
      sent_data_dso                Date.parse('2016-09-17')
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
    end
  end
end
