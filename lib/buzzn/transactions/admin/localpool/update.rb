require_relative '../localpool'
require_relative '../../../schemas/transactions/admin/localpool/update_with_address'
require_relative '../../../schemas/transactions/admin/localpool/update_without_address'

class Transactions::Admin::Localpool::Update < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update'
  around :db_transaction
  tee :create_or_update_address, with: :'operations.action.create_or_update_address'
  map :update_localpool, with: :'operations.action.update'

  def schema(resource:, **)
    if resource.address
      Schemas::Transactions::Admin::Localpool::UpdateWithAddress
    else
      Schemas::Transactions::Admin::Localpool::UpdateWithoutAddress
    end
  end

end
