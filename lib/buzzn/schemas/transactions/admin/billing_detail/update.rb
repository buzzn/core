require_relative '../../../constraints/billing_detail'
require_relative '../billing_detail'

Schemas::Transactions::Admin::BillingDetail::Update = Schemas::Support.Form(Schemas::Transactions::Update) do
  optional(:reduced_power_amount).filled(:float?).value(gteq?: 0)
  optional(:reduced_power_factor).filled(:float?).value(gteq?: 0).value(lt?: 1)
  optional(:automatic_abschlag_adjust).filled(:bool?)
  optional(:automatic_abschlag_threshold_cents).filled(:float?).value(gteq?: 0)
  optional(:issues_vat).filled(:bool?)
  optional(:leg_single).filled(:bool?)
end
