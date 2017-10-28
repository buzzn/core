require_relative '../account'

# NOTE: implemented in rodauth, the schema is only used to generate
#       swagger.json.

Schemas::Transactions::Account::Login = Buzzn::Schemas.Form do
  required(:login).filled(:str?, max_size?: 64)
  required(:password).filled(:str?, max_size?: 64)
end
