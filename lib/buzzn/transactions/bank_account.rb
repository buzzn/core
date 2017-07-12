require_relative 'resource'
Buzzn::Transaction.define do |t|
  t.register_validation(:create_bank_account_schema) do
    required(:bank_name).filled(:str?, max_size?: 64)
    required(:holder).filled(:str?, max_size?: 64)
    required(:iban).filled(:str?, :iban?, max_size?: 32)
  end

  t.register_validation(:update_bank_account_schema) do
    optional(:bank_name).filled(:str?, max_size?: 64)
    optional(:holder).filled(:str?, max_size?: 64)
    optional(:iban).filled(:str?, :iban?, max_size?: 32)
  end

  t.define(:create_bank_account) do
    validate :create_bank_account_schema
    step :resource, with: :nested_resource
  end

  t.define(:update_bank_account) do
    validate :update_bank_account_schema
    step :resource, with: :update_resource
  end
end
