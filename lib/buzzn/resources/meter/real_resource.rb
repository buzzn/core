require_relative 'base_resource'

module Meter
  class RealResource < BaseResource

    model Real

    attributes :manufacturer_name,
               :manufacturer_description,
               :location_description,
               :direction_number,
               :converter_constant,
               :ownership,
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
               :sent_data_dso,
               :data_source


    has_many :registers

    def data_source
      object.registers.first&.data_source
    end
  end
end
