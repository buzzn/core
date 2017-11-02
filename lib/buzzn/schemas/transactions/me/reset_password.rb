require_relative '../me'

# NOTE: implemented in rodauth, the schema is only used to generate
#       swagger.json.

Schemas::Transactions::Me::ResetPassword = Buzzn::Schemas.Form do
  required(:login).filled(:str?, max_size?: 64)
end
