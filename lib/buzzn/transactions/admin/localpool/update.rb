require_relative '../localpool'
require_relative '../../../schemas/transactions/admin/localpool/update'

class Transactions::Admin::Localpool::Update < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update_ng'
  step :persist, with: :'operations.action.update_ng'

  def schema
    Schemas::Transactions::Admin::Localpool::Update
  end

end
