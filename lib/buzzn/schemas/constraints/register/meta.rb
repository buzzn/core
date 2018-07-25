require './app/models/register/meta.rb'
require_relative '../register'

Schemas::Constraints::Register::Meta = Schemas::Support.Form do
  required(:name).filled(:str?, max_size?: 64)
  required(:label).value(included_in?: Register::Meta.labels.values)
  required(:share_with_group).filled(:bool?)
  required(:share_publicly).filled(:bool?)
  optional(:observer_enabled).filled(:bool?)
  optional(:observer_min_threshold).filled(:int?, gteq?: 0)
  optional(:observer_max_threshold).filled(:int?, gteq?: 0)
  optional(:observer_offline_monitoring).filled(:bool?)
end
