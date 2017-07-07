require_relative 'resource'
Buzzn::Transaction.define do |t|
  t.register_validation(:update_real_meter_schema) do
    optional(:manufacturer_name)
      .value(included_in?: Meter::Real::MANUFACTURER_NAMES)
    optional(:product_name).filled(:str?, max_size?: 63)
    optional(:product_serialnumber).filled(:str?, max_size?: 63)
    optional(:ownership).value(included_in?: Meter::Base::OWNERSHIPS)
    optional(:section).value(included_in?: Meter::Base::SECTIONS)
    optional(:build_year).filled(:int?)
    optional(:converter_constant).filled(:int?)
    optional(:calibrated_until).filled(:date?)
    optional(:edifact_metering_type).value(included_in?: Meter::Base::METERING_TYPES)
    optional(:edifact_meter_size).value(included_in?: Meter::Base::METER_SIZES)
    optional(:edifact_measurement_method).filled(:str?, max_size?: 63)
    optional(:edifact_tariff).value(included_in?: Meter::Base::TARIFFS)
    optional(:edifact_mounting_method).value(included_in?: Meter::Base::MOUNTING_METHODS)
    optional(:edifact_voltage_level).value(included_in?: Meter::Base::VOLTAGE_LEVELS)
    optional(:edifact_cycle_interval).value(included_in?: Meter::Base::CYCLE_INTERVALS)
    optional(:edifact_data_logging).value(included_in?: Meter::Base::DATA_LOGGINGS)
  end

  t.register_validation(:update_virtual_meter_schema) do
    optional(:product_name).filled(:str?, max_size?: 63)
    optional(:product_serialnumber).filled(:str?, max_size?: 63)
    optional(:ownership).value(included_in?: Meter::Base::OWNERSHIPS)
    optional(:section).value(included_in?: Meter::Base::SECTIONS)
    optional(:build_year).filled(:int?)
    optional(:converter_constant).filled(:int?)
    optional(:calibrated_until).filled(:date?)
    optional(:edifact_metering_type).value(included_in?: Meter::Base::METERING_TYPES)
    optional(:edifact_meter_size).value(included_in?: Meter::Base::METER_SIZES)
    optional(:edifact_measurement_method).filled(:str?, max_size?: 63)
    optional(:edifact_tariff).value(included_in?: Meter::Base::TARIFFS)
    optional(:edifact_mounting_method).value(included_in?: Meter::Base::MOUNTING_METHODS)
    optional(:edifact_voltage_level).value(included_in?: Meter::Base::VOLTAGE_LEVELS)
    optional(:edifact_cycle_interval).value(included_in?: Meter::Base::CYCLE_INTERVALS)
    optional(:edifact_data_logging).value(included_in?: Meter::Base::DATA_LOGGINGS)
  end

  t.define(:update_real_meter) do
    validate :update_real_meter_schema
    step :resource, with: :update_resource
  end

  t.define(:update_virtual_meter) do
    validate :update_virtual_meter_schema
    step :resource, with: :update_resource
  end
end
