require_relative '../bank_account'

Schemas::Transactions::BankAccount::Update = Buzzn::Schemas.Form(Schemas::Transactions::Update) do
  optional(:bank_name).filled(:str?, max_size?: 64)
  optional(:holder).filled(:str?, max_size?: 64)
  optional(:iban).filled(:iban?, max_size?: 32)
end
