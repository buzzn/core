require_relative 'resource'
require_relative '../schemas/transactions/admin/price/create'
require_relative '../schemas/transactions/admin/price/update'

Buzzn::Transaction.define do |t|
  t.define(:create_price) do
    validate Schemas::Transactions::Admin::Price::Create
    step :resource, with: :nested_resource
  end

  t.define(:update_price) do
    validate Schemas::Transactions::Admin::Price::Update
    step :resource, with: :update_resource
  end
end
