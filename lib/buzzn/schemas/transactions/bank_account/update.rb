require_relative '../bank_account'

Schemas::Transactions::BankAccount::Update = Schemas::Support.Form(Schemas::Transactions::Update) do
  optional(:holder).filled(:str?, max_size?: 64)
  optional(:iban).filled(:str?, :iban?, max_size?: 32)
  optional(:bank_name).filled(:str?, max_size?: 64)
  optional(:bic).filled(:str?, max_size?: 16, min_size?: 8) # iso-9362
  optional(:direct_debit).filled(:bool?)
end
