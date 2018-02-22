require_relative '../billing_cycle'

Schemas::Transactions::Admin::BillingCycle::Update = Schemas::Support.Form(Schemas::Transactions::Update) do
  optional(:name).filled(:str?, max_size?: 64)
  optional(:end_date).filled(:date?)
end
