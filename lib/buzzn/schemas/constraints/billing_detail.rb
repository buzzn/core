require_relative '../constraints'

Schemas::Constraints::BillingDetail = Schemas::Support.Form do
  optional(:reduced_power_amount).value(:float?, gteq?: 0)
  optional(:reduced_power_factor).value(:float?, gteq?: 0, lt?: 1)
  optional(:automatic_abschlag_adjust).maybe(:bool?)
  optional(:automatic_abschlag_threshold).value(:float?, gteq?: 0)
end
