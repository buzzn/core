require_relative '../constraints'

Schemas::Constraints::Bank_Account = Buzzn::Schemas.Form do
  required(:bank_name).filled(:str?, max_size?: 64)
  required(:holder).filled(:str?, max_size?: 64)
  required(:iban).filled(:str?, :iban?, max_size?: 32)
end
