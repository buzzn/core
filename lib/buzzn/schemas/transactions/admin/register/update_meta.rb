require_relative '../../update'
require_relative '../register'

require './app/models/register/meta'

Schemas::Transactions::Admin::Register::UpdateMeta = Schemas::Support.Form(Schemas::Transactions::Update) do

  optional(:name).filled(:str?, max_size?: 64)
  optional(:label).value(included_in?: Register::Meta.labels.values)
  optional(:observer_enabled).filled(:bool?)
  optional(:observer_min_threshold).maybe(:int?, gteq?: 0)
  optional(:observer_max_threshold).maybe(:int?, gteq?: 0)
  optional(:observer_offline_monitoring).filled(:bool?)
  optional(:market_location_id).maybe(:str?, size?: 11)

end
