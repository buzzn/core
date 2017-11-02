require_relative '../constraints'

Schemas::Constraints::BankAccount = Buzzn::Schemas.Form do
  required(:holder).filled(:str?, max_size?: 64)
  required(:iban).filled(:str?, :iban?, max_size?: 32)
  optional(:bank_name).filled(:str?, max_size?: 64)
  optional(:bic).filled(:str?, max_size?: 16, min_size?: 8) # iso-9362
  optional(:direct_debit).filled(:bool?)
end
