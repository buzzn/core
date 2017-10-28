require_relative '../billing'

Schemas::Transactions::Billing::CreateRegular = Buzzn::Schemas.Form do
  required(:accounting_year).filled(:int?)
end
