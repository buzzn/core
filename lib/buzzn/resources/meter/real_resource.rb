module Meter
  class RealResource < BaseResource

    model Real

    attributes :manufacturer_name,
               :direction_number,
               :converter_constant,
               :ownership,
               :section,
               :build_year,
               :calibrated_until,
               :edifact_metering_type,
               :edifact_meter_size,
               :edifact_tariff,
               :edifact_measurement_method,
               :edifact_mounting_method,
               :edifact_voltage_level,
               :edifact_cycle_interval,
               :edifact_data_logging,
               :sent_data_dso


    has_many :registers
    has_one :address
  end
end
