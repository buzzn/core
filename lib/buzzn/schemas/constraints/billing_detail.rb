require_relative '../constraints'

Schemas::Constraints::BillingDetail = Schemas::Support.Form do
  required(:issues_vat).value(:bool?)
  required(:leg_single).value(:bool?)
  required(:reduced_power_amount).value(:float?, gteq?: 0)
  required(:reduced_power_factor).value(:float?, gteq?: 0, lt?: 1)
  required(:automatic_abschlag_adjust).value(:bool?)
  required(:automatic_abschlag_threshold_cents).value(:float?, gteq?: 0)
  optional(:leg_single).value(:bool?)
end
