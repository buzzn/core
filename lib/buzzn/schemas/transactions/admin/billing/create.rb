require_relative '../billing'
require './app/models/billing.rb'

Schemas::Transactions::Admin::Billing::Create = Schemas::Support.Form do
  required(:begin_date).filled(:date?)
  required(:end_date).filled(:date?)
  optional(:status).value(included_in?: Billing.status.values)
  optional(:invoice_number).maybe(:str?, max_size?: 64)
end
