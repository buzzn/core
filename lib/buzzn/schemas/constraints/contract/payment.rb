require_relative '../contract'

Schemas::Constraints::Contract::Payment = Schemas::Support.Form do
  required(:begin_date).filled(:date?)
  required(:price_cents).filled(:int?, gt?: 0)
  required(:energy_consumption_kwh_pa).filled(:int?, gt?: 0)
  optional(:cycle).value(included_in?: Contract::Payment.cycles.values)
end
