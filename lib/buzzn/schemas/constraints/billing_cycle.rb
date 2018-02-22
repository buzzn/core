require_relative '../constraints'

Schemas::Constraints::BillingCycleCommon = Schemas::Support.Form do
  required(:name).filled(:str?, max_size?: 64)
end

Schemas::Constraints::BillingCycle = Schemas::Support.Form(Schemas::Constraints::BillingCycleCommon) do
  required(:begin_date).filled(:date?)
  required(:end_date).filled(:date?)
end
