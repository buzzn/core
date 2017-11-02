require_relative '../billing'

Schemas::Transactions::Admin::Billing::CreateRegular = Buzzn::Schemas.Form do
  required(:accounting_year).filled(:int?)
end
