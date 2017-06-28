require_relative 'resource'
Buzzn::Transaction.define do |t|
  t.register_validation(:update_real_meter_schema) do
    optional(:manufacturer_name)
      .value(included_in?: Meter::Real.all_manufacturer_names)
    optional(:manufacturer_product_name).filled(:str?, max_size?: 63)
    optional(:manufacturer_product_serialnumber).filled(:str?, max_size?: 63)
    optional(:metering_type).value(included_in?: Meter::Base.all_metering_types)
    optional(:meter_size).value(included_in?: Meter::Base.all_meter_sizes)
    optional(:ownership).value(included_in?: Meter::Base.all_ownerships)
    optional(:build_year).filled(:int?) # TODO rough lower and upper bound
  end

  t.register_validation(:update_virtual_meter_schema) do
    optional(:manufacturer_product_name).filled(:str?, max_size?: 63)
    optional(:manufacturer_product_serialnumber).filled(:str?, max_size?: 63)
    optional(:metering_type).value(included_in?: Meter::Base.all_metering_types)
    optional(:meter_size).value(included_in?: Meter::Base.all_meter_sizes)
    optional(:ownership).value(included_in?: Meter::Base.all_ownerships)
    optional(:build_year).filled(:int?) # TODO rough lower and upper bound
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
