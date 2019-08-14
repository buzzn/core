require_relative '../register'
require_relative '../../../constraints/register/meta'

Schemas::Transactions::Admin::Register::CreateMeta = Schemas::Support.Form(Schemas::Constraints::Register::Meta) do
  optional(:market_location_id).value(:str?, size?: 11)
end

Schemas::Transactions::Admin::Register::CreateMetaLoose = Schemas::Support.Form do

  optional(:id).value(:int?)
  optional(:name).value(:str?, max_size?: 64)
  optional(:label).value(included_in?: Register::Meta.labels.values)
  optional(:observer_enabled).value(:bool?)
  optional(:observer_min_threshold).maybe(:int?, gteq?: 0)
  optional(:observer_max_threshold).maybe(:int?, gteq?: 0)
  optional(:observer_offline_monitoring).value(:bool?)
  optional(:market_location_id).maybe(:str?, size?: 11)

end
