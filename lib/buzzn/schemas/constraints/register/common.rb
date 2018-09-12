require './app/models/register/meta.rb'
require_relative '../register'

Schemas::Constraints::Register::Common = Schemas::Support.Form do
  optional(:name).filled(:str?, max_size?: 64)
  optional(:label).value(included_in?: Register::Meta.labels.values)
  optional(:observer_enabled).filled(:bool?)
  optional(:observer_min_threshold).filled(:int?, gteq?: 0)
  optional(:observer_max_threshold).filled(:int?, gteq?: 0)
  optional(:observer_offline_monitoring).filled(:bool?)
end
