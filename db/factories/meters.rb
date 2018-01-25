FactoryGirl.define do
  factory :meter do
    transient do
      registers nil
      register_direction :input
    end

    group                        { FactoryGirl.create(:localpool) }
    direction_number             :one_way_meter

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
          meter.registers = [ FactoryGirl.build(:register, evaluator.register_direction, meter: meter) ]
        end
      end
    end

    trait :with_broker do
      broker                     { Broker::Discovergy.new }
    end

    trait :one_way do
      direction_number           :one_way_meter
      converter_constant         1
    end

    trait :two_way do
      direction_number           :two_way_meter
      converter_constant         40
    end

    trait :real do
      initialize_with              { Meter::Real.new }
      manufacturer_name            :easy_meter
      manufacturer_description     { generate(:meter_manufacturer_description) }
      location_description         { generate(:meter_location_description) }
      product_serialnumber         { generate(:meter_serial_number) }
      product_name                 "Q3D"
      calibrated_until             Date.parse("2027-10-13")
      converter_constant           1
      ownership                    :buzzn
      build_year                   2015
      sent_data_dso                Date.parse("2016-09-17")
      # edifact data
      edifact_metering_type        :digital_household_meter
      edifact_meter_size           :edl40
      edifact_measurement_method   :remote
      edifact_mounting_method      :three_point_mounting
      edifact_voltage_level        :low_level
      edifact_cycle_interval       :yearly
      edifact_tariff               :single_tariff
      edifact_data_logging         :electronic
    end

    trait :virtual do
      initialize_with             { Meter::Virtual.new }
      manufacturer_name           nil
      direction_number            nil
      product_name                "buzzn virtual meter"
    end
  end
end
