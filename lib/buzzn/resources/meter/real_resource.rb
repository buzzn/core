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

    # API methods for the endpoints

    def create_input_register(params)
      params[:meter] = object
      Register::Input.guarded_create(current_user, params)
    end

    def create_output_register(params)
      params[:meter] = object
      Register::Output.guarded_create(current_user, params)
    end
  end
end
