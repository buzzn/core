require_relative '../register'
require_relative '../../../schemas/transactions/admin/register/update_real'

class Transactions::Admin::Register::UpdateReal < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update'
  map :persist, with: :'operations.action.update'

  def schema
    Schemas::Transactions::Admin::Register::UpdateReal
  end

  def persist(resource:, params:, **)
    resource.object.meta.update!(params.except(:metering_point_id, :updated_at))
    # note: there is actually no data on register which can be updated
    super(resource: resource, params: params.slice(:updated_at))
  end

end
