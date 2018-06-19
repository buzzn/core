require_relative '../localpool'
require_relative '../../../schemas/transactions/admin/localpool/update'

class Transactions::Admin::Localpool::Update < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update'
  around :db_transaction
  tee :create_or_update_address, with: :'operations.action.create_or_update_address'
  map :update_localpool, with: :'operations.action.update'

  def schema(resource:, **)
    Schemas::Transactions::Admin::Localpool.update_for(resource)
  end

end
