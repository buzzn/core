require_relative 'common'
require_relative '../../../../../app/models/meter/real'

Schemas::Constraints::Meter::Base = Schemas::Support.Form(Schemas::Constraints::Meter::Common) do
  required(:direction_number).maybe(included_in?: Meter::Real.direction_numbers.values)

  optional(:datasource).maybe(included_in?: Meter::Real.datasources.values)
  optional(:product_name).maybe(:str?, max_size?: 64)
  optional(:manufacturer_name).maybe(included_in?: Meter::Real.manufacturer_names.values)
  optional(:manufacturer_description).maybe(:str?)
  optional(:location_description).maybe(:str?)
  optional(:ownership).maybe(included_in?: Meter::Real.ownerships.values)
  optional(:build_year).maybe(:int?, lt?: 2050)
  optional(:sent_data_dso).maybe(:date?)
  optional(:converter_constant).maybe(:int?)
  optional(:calibrated_until).maybe(:date?)
  optional(:edifact_metering_type).maybe(included_in?: Meter::Real.edifact_metering_types.values)
  optional(:edifact_meter_size).maybe(included_in?: Meter::Real.edifact_meter_sizes.values)
  optional(:edifact_measurement_method).maybe(included_in?: Meter::Real.edifact_measurement_methods.values)
  optional(:edifact_tariff).maybe(included_in?: Meter::Real.edifact_tariffs.values)
  optional(:edifact_mounting_method).maybe(included_in?: Meter::Real.edifact_mounting_methods.values)
  optional(:edifact_voltage_level).maybe(included_in?: Meter::Real.edifact_voltage_levels.values)
  optional(:edifact_cycle_interval).maybe(included_in?: Meter::Real.edifact_cycle_intervals.values)
  optional(:edifact_data_logging).maybe(included_in?: Meter::Real.edifact_data_loggings.values)
end
