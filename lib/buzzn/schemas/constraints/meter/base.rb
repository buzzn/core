require_relative 'common'

Schemas::Constraints::Meter::Base = Buzzn::Schemas.Form(Schemas::Constraints::Meter::Common) do
  optional(:manufacturer_name).value(included_in?: Meter::Real.manufacturer_names.values)
  optional(:ownership).value(included_in?: Meter::Real.ownerships.values)
  optional(:section).value(included_in?: Meter::Real.sections.values)
  optional(:build_year).filled(:int?, gt?: 1950, lt?: 2050)
  optional(:sent_data_dso).filled(:date?)
  optional(:converter_constant).filled(:int?)
  optional(:calibrated_until).filled(:date?)
  optional(:direction_number).value(included_in?: Meter::Real.direction_numbers.values)
  optional(:edifact_metering_type).value(included_in?: Meter::Real.edifact_metering_types.values)
  optional(:edifact_meter_size).value(included_in?: Meter::Real.edifact_meter_sizes.values)
  optional(:edifact_measurement_method).value(included_in?: Meter::Real.edifact_measurement_methods.values)
  optional(:edifact_tariff).value(included_in?: Meter::Real.edifact_tariffs.values)
  optional(:edifact_mounting_method).value(included_in?: Meter::Real.edifact_mounting_methods.values)
  optional(:edifact_voltage_level).value(included_in?: Meter::Real.edifact_voltage_levels.values)
  optional(:edifact_cycle_interval).value(included_in?: Meter::Real.edifact_cycle_intervals.values)
  optional(:edifact_data_logging).value(included_in?: Meter::Real.edifact_data_loggings.values)
end
