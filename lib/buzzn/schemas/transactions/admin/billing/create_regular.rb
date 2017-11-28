require_relative '../billing'

Schemas::Transactions::Admin::Billing::CreateRegular = Schemas::Support.Form do
  required(:accounting_year).filled(:int?)
end
