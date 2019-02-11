require_relative '../bank_account'

Schemas::Transactions::BankAccount::Assign = Schemas::Support.Form(Schemas::Transactions::Update) do
  optional(:bank_account_id).filled(:int?)
end
