require_relative 'resource'
require_relative '../schemas/transactions/admin/billing_cycle/create'
require_relative '../schemas/transactions/admin/billing_cycle/update'

Buzzn::Transaction.define do |t|

  t.define(:create_billing_cycle) do
    validate Schemas::Transactions::Admin::BillingCycle::Create
    step :resource, with: :nested_resource
  end

  t.define(:update_billing_cycle) do
    validate Schemas::Transactions::Admin::BillingCycle::Update
    step :resource, with: :update_resource
  end
end
