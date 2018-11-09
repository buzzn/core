require './app/models/register/meta.rb'
require_relative '../register'

Schemas::Constraints::Register::Meta = Schemas::Support.Form do
  required(:name).filled(:str?, max_size?: 64)
  required(:label).value(included_in?: Register::Meta.labels.values)
  optional(:observer_enabled).value(:bool?)
  optional(:observer_min_threshold).maybe(:int?, gteq?: 0)
  optional(:observer_max_threshold).maybe(:int?, gteq?: 0)
  optional(:observer_offline_monitoring).value(:bool?)
end
