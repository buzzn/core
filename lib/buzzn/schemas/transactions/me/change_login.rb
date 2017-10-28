require_relative '../me'

# NOTE: implemented in rodauth, the schema is only used to generate
#       swagger.json.

Schemas::Transactions::Me::ChangeLogin = Buzzn::Schemas.Form do
  required(:password).filled(:str?, max_size?: 64)
  required(:login).filled(:str?, max_size?: 64)
  required(:'login-confirm').filled(:str?, max_size?: 64)
end
