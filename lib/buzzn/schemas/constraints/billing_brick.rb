require_relative '../constraints'

Schemas::Constraints::BillingBrick = Schemas::Support.Form do
  required(:begin_date).filled(:date?)
  required(:end_date).filled(:date?)
  required(:contract_type).value(included_in?: BillingBrick.contract_types.values)
end
