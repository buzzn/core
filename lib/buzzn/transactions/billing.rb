require_relative 'resource'
require_relative '../schemas/transactions/admin/billing/create_regular'
require_relative '../schemas/transactions/admin/billing/update'

Buzzn::Transaction.define do |t|

  t.define(:create_regular_billings) do
    validate Schemas::Transactions::Admin::Billing::CreateRegular
    step :resource, with: :nested_resource
  end

  t.define(:update_billing) do
    validate Schemas::Transactions::Admin::Billing::Update
    step :resource, with: :update_resource
  end
end
