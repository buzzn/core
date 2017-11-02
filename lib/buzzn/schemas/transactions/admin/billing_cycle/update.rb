require_relative '../billing_cycle'

Schemas::Transactions::Admin::BillingCycle::Update = Buzzn::Schemas.Form(Schemas::Transactions::Update) do
  optional(:name).filled(:str?, max_size?: 64)
  optional(:begin_date).filled(:date?)
  optional(:end_date).filled(:date?)
end
