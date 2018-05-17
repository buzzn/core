require_relative '../localpool'
require_relative '../../../schemas/transactions/admin/localpool/update'

class Transactions::Admin::Localpool::Update < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update'
  map :persist, with: :'operations.action.update'

  def schema
    Schemas::Transactions::Admin::Localpool::Update
  end

end
