require_relative '../constraints'

Schemas::Constraints::BillingCycle = Buzzn::Schemas.Form do
  required(:name).filled(:str?, max_size?: 64)
  required(:begin_date).filled(:date?)
  required(:end_date).filled(:date?)
end
