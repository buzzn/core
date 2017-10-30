require_relative 'resource'
require_relative '../schemas/constraints/person'
require_relative '../schemas/transactions/admin/localpool/create'
require_relative '../schemas/transactions/admin/localpool/update'

Buzzn::Transaction.define do |t|
  t.define(:create_localpool) do
    validate Schemas::Transactions::Admin::Localpool::Create
    step :resource, with: :nested_resource
  end

  t.define(:create_localpool_owner) do
    step :validate, with: :constraints
    step :build, with: :build
    step :assign, with: :method
  end

  t.define(:assign_localpool_owner) do
    step :find, with: :retrieve
    step :assign, with: :method
  end

  t.define(:update_localpool) do
    validate Schemas::Transactions::Admin::Localpool::Update
    step :resource, with: :update_resource
  end
end
