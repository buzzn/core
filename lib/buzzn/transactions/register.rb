require_relative 'resource'
require_relative '../schemas/transactions/admin/register/update_real'
require_relative '../schemas/transactions/admin/register/update_virtual'

Buzzn::Transaction.define do |t|

  t.register_validation(:update_virtual_register_schema) do
    required(:updated_at).filled(:date_time?)
  end

  t.define(:update_real_register) do
    validate Schemas::Transactions::Admin::Register::UpdateReal
    step :resource, with: :update_resource
  end

  t.define(:update_virtual_register) do
    validate Schemas::Transactions::Admin::Register::UpdateVirtual
    step :resource, with: :update_resource
  end
end
