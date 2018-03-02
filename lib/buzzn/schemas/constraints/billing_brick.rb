require_relative '../constraints'

Schemas::Constraints::BillingBrick = Schemas::Support.Form do
  required(:begin_date).filled(:date?)
  required(:end_date).filled(:date?)
  required(:status).value(included_in?: BillingBrick.status.values)
  required(:contract_type).value(included_in?: BillingBrick.types.values)
end
