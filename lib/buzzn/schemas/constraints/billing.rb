require_relative '../constraints'

Schemas::Constraints::Billing = Buzzn::Schemas.Form do
  required(:status).value(included_in?: Billing.status.values)
  required(:total_energy_consumption_kwh).filled(:int?, gteq?: 0)
  required(:total_price_cents).filled(:int?, gteq?: 0)
  required(:prepayments_cents).filled(:int?, gteq?: 0)
  #may be negative if LSG has to pay back money
  required(:receivables_cents).filled(:int?)
  optional(:invoice_number).filled(:str?, max_size?: 64)
end
