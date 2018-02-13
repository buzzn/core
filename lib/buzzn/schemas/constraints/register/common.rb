require_relative '../register'

Schemas::Constraints::Register::Common = Schemas::Support.Form do
  optional(:metering_point_id).filled(:str?, max_size?: 64)
  optional(:label).value(included_in?: Register::Base.labels.values)
  optional(:observer_enabled).filled(:bool?)
  optional(:observer_min_threshold).filled(:int?, gteq?: 0)
  optional(:observer_max_threshold).filled(:int?, gteq?: 0)
  optional(:observer_offline_monitoring).filled(:bool?)
  # Not sure why this can't be here, or if it should. When enabled, this test breaks:
  # this test rspec ./spec/requests/admin/register_spec.rb:109
  # optional(:market_location_id).filled(:int?, gteq?: 1)
end
