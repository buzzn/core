require_relative '../register'
require_relative '../../../constraints/register/meta'

Schemas::Transactions::Admin::Register::CreateMeta = Schemas::Constraints::Register::Meta

Schemas::Transactions::Admin::Register::CreateMetaLoose = Schemas::Support.Form do

  optional(:id).value(:int?)
  optional(:name).value(:str?, max_size?: 64)
  optional(:label).value(included_in?: Register::Meta.labels.values)
  optional(:observer_enabled).value(:bool?)
  optional(:observer_min_threshold).value(:int?, gteq?: 0)
  optional(:observer_max_threshold).value(:int?, gteq?: 0)
  optional(:observer_offline_monitoring).value(:bool?)

end
