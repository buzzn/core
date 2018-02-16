require_relative '../register'

Schemas::Constraints::Register::Common = Schemas::Support.Form do
  required(:label).value(included_in?: Register::Base.labels.values)
  optional(:metering_point_id).filled(:str?, max_size?: 64)
  optional(:observer_enabled).filled(:bool?)
  optional(:observer_min_threshold).filled(:int?, gteq?: 0)
  optional(:observer_max_threshold).filled(:int?, gteq?: 0)
  optional(:observer_offline_monitoring).filled(:bool?)
end
