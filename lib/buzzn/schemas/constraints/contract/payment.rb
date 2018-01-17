require_relative '../contract'

Schemas::Constraints::Contract::Payment = Schemas::Support.Form do
  required(:begin_date).filled(:date?)
  required(:price_cents).filled(:int?, gt?: 0)
  optional(:end_date).filled(:date?)
  optional(:cycle).value(included_in?: Contract::Payment.cycles.values)
end
