require_relative 'resource'
require_relative '../schemas/transactions/admin/meter/update_real'
require_relative '../schemas/transactions/admin/meter/update_virtual'

Buzzn::Transaction.define do |t|

  t.define(:update_real_meter) do
    validate Schemas::Transactions::Admin::Meter::UpdateReal
    step :resource, with: :update_resource
  end

  t.define(:update_virtual_meter) do
    validate Schemas::Transactions::Admin::Meter::UpdateVirtual
    step :resource, with: :update_resource
  end
end
