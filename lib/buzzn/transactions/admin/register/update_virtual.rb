require_relative '../register'
require_relative '../../../schemas/transactions/admin/register/update_virtual'

class Transactions::Admin::Register::UpdateVirtual < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update_ng'
  step :persist, with: :'operations.action.update_ng'

  def schema
    Schemas::Transactions::Admin::Register::UpdateVirtual
  end

end
