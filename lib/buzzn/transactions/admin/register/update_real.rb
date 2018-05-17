require_relative '../register'
require_relative '../../../schemas/transactions/admin/register/update_real'

class Transactions::Admin::Register::UpdateReal < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update_ng'
  step :persist, with: :'operations.action.update_ng'

  def schema
    Schemas::Transactions::Admin::Register::UpdateReal
  end

end
