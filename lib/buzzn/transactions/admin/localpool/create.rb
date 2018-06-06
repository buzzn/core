require_relative '../localpool'
require_relative '../../../schemas/transactions/admin/localpool/create'

class Transactions::Admin::Localpool::Create < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.create'
  around :db_transaction
  tee :create_address, with: :'operations.action.create_or_update_address'
  map :create_localpool, with: :'operations.action.create_item'

  def schema
    Schemas::Transactions::Admin::Localpool::Create
  end

  def create_address(params:, **)
    super(params: params, resource: nil)
  end

  def create_localpool(params:, resource:)
    Admin::LocalpoolResource.new(
      *super(resource, params)
    )
  end

end
