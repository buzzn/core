require_relative '../me'

# NOTE: implemented in rodauth, the schema is only used to generate
#       swagger.json.

Schemas::Transactions::Me::VerifyChangeLogin = Buzzn::Schemas.Form do
  required(:key).filled(:str?, max_size?: 64)
end
