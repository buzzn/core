require_relative '../constraints'

Schemas::Constraints::BillingBrick = Schemas::Support.Form do
  required(:begin_date).filled(:date?)
  required(:end_date).filled(:date?)
end
