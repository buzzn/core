require_relative 'resource'
Buzzn::Transaction.define do |t|
  t.register_validation(:update_bank_account_schema) do
    optional(:bank_name).filled(:str?)
    optional(:holder).filled(:str?)
    optional(:iban).filled(:str?)
  end

  t.define(:update_bank_account) do
    validate :update_bank_account_schema
    step :resource, with: :update_resource
  end
end
