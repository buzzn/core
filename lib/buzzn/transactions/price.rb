require_relative 'resource'
require_relative '../schemas/transactions/price/create'
require_relative '../schemas/transactions/price/update'

Buzzn::Transaction.define do |t|
  t.define(:create_price) do
    validate Schemas::Transactions::Price::Create
    step :resource, with: :nested_resource
  end

  t.define(:update_price) do
    validate Schemas::Transactions::Price::Update
    step :resource, with: :update_resource
  end
end
