require_relative 'resource'
Buzzn::Transaction.define do |t|
  t.register_validation(:login_schema) do
    required(:login).filled(:str?, max_size?: 64)
    required(:password).filled(:str?, max_size?: 64)
  end

  t.register_validation(:logout_schema) do
  end

  t.register_validation(:reset_password_request_schema) do
    required(:key).filled(:str?, max_size?: 64)
    required(:password).filled(:str?, max_size?: 64)
    required(:'password-confirm').filled(:str?, max_size?: 64)
  end

  t.register_validation(:reset_password_schema) do
    required(:login).filled(:str?, max_size?: 64)
  end

  t.register_validation(:change_login_schema) do
    required(:password).filled(:str?, max_size?: 64)
    required(:login).filled(:str?, max_size?: 64)
    required(:'login-confirm').filled(:str?, max_size?: 64)
  end

  t.register_validation(:verify_login_change_schema) do
    required(:key).filled(:str?, max_size?: 64)
  end

  # NOTE: implemented in rodauth, the above validations are only used to
  # generate swagger.json.
  # t.define(:create_session)
end
