module Meter
  class BaseResource < Buzzn::Resource::Entity

    abstract

    model Base

    attributes :product_name,
               :product_serialnumber,
               :ownership,
               :build_year,
               :calibrated_until,
               :edifact_metering_type,
               :edifact_meter_size,
               :edifact_section,
               :edifact_tariff,
               :edifact_measurement_method,
               :edifact_mounting_method,
               :edifact_meter_size,
               :edifact_voltage_level,
               :edifact_cycle_interval

    attributes :updatable, :deletable

  end
end
