require_relative '../billing'

Schemas::Transactions::Admin::Billing::Update = Schemas::Support.Form(Schemas::Transactions::Update) do
  optional(:receivables_cents).filled(:int?)
  optional(:invoice_number).filled(:str?, max_size?: 64)
  optional(:status).value(included_in?: Billing.status.values)
end
