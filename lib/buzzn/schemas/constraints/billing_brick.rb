require_relative '../constraints'

Schemas::Constraints::BillingBrick = Schemas::Support.Form do
  required(:begin_date).filled(:date?)
  required(:end_date).filled(:date?)
  required(:status).value(included_in?: BillingBrick.status.values)
  required(:end_date).filled(:date?)
end
