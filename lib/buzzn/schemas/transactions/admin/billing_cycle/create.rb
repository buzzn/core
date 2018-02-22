require_relative '../../../constraints/billing_cycle'
require_relative '../billing_cycle'

Schemas::Transactions::Admin::BillingCycle::Create = Schemas::Support.Form(Schemas::Constraints::BillingCycleCommon) do
  required(:last_date).filled(:date?)
end
