require_relative '../register'
require_relative '../../../schemas/transactions/admin/register/update_virtual'

class Transactions::Admin::Register::UpdateVirtual < Transactions::Base

  def self.for(register)
    super(register, :authorize, :persist)
  end

  validate :schema
  step :authorize, with: :'operations.authorization.update'
  step :persist, with: :'operations.action.update'

  def schema
    Schemas::Transactions::Admin::Register::UpdateVirtual
  end

end
