require_relative '../billing'
require './app/models/billing.rb'

Schemas::Transactions::Admin::Billing::Create = Schemas::Support.Form do
  required(:begin_date).filled(:date?)
  required(:last_date).filled(:date?)
  optional(:invoice_number).maybe(:str?, max_size?: 64)
end
