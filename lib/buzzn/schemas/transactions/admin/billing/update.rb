require_relative '../billing'
require './app/models/billing.rb'

Schemas::Transactions::Admin::Billing::Update = Schemas::Support.Form(Schemas::Transactions::Update) do
  optional(:invoice_number).filled(:str?, max_size?: 64)
  optional(:status).value(included_in?: Billing.status.values)
end
