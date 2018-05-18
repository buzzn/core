require_relative '../reading'
require_relative '../../../schemas/transactions/admin/reading/create'

class Transactions::Admin::Reading::Create < Transactions::Base

  validate :schema
  authorize :allowed_roles
  map :create_reading, with: :'operations.action.create_item'

  def schema
    Schemas::Transactions::Admin::Reading::Create
  end

  def allowed_roles(permission_context:)
    permission_context.readings.create
  end

  def create_reading(params:, resource:)
    ReadingResource.new(
      *super(resource.readings, params)
    )
  end

end
