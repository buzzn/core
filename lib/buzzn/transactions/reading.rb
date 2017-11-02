require_relative 'resource'
require_relative '../schemas/transactions/admin/reading/create'

Buzzn::Transaction.define do |t|
  t.define(:create_reading) do
    validate Schemas::Transactions::Admin::Reading::Create
    step :resource, with: :nested_resource
  end
end
