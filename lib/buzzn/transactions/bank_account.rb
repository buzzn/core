require_relative 'resource'
require_relative '../schemas/transactions/bank_account/create'
require_relative '../schemas/transactions/bank_account/update'

Buzzn::Transaction.define do |t|
  t.define(:create_bank_account) do
    validate Schemas::Transactions::BankAccount::Create
    step :resource, with: :nested_resource
  end

  t.define(:update_bank_account) do
    validate Schemas::Transactions::BankAccount::Update
    step :resource, with: :update_resource
  end
end
