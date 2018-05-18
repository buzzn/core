require_relative '../localpool'
require_relative '../../../schemas/transactions/admin/localpool/create'

class Transactions::Admin::Localpool::Create < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.create'
  map :create_localpool, with: :'operations.action.create_item'

  def schema
    Schemas::Transactions::Admin::Localpool::Create
  end

  def create_localpool(params:, resource:)
    Admin::LocalpoolResource.new(
      *super(resource, params)
    )
  end

end
