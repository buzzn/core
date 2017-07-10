module Meter
  class BaseResource < Buzzn::Resource::Entity

    abstract

    model Base

    attributes :product_name,
               :product_serialnumber,
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

    attributes :updatable, :deletable

  end
end

