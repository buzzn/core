require_relative '../billing'

Schemas::Transactions::Billing::Update = Buzzn::Schemas.Form(Schemas::Transactions::Update) do
  optional(:receivables_cents).filled(:int?)
  optional(:invoice_number).filled(:str?, max_size?: 64)
  optional(:status).value(included_in?: Billing.status.values)
end
