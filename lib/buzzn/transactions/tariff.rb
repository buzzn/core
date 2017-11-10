require_relative 'resource'
require_relative '../schemas/transactions/admin/tariff/create'
Buzzn::Transaction.define do |t|

  t.define(:create_tariff) do
    validate Schemas::Transactions::Admin::Tariff::Create
    step :resource, with: :nested_resource
  end
end
