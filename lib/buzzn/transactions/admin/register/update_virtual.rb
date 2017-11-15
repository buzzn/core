require_relative '../register'
require_relative '../../../schemas/transactions/admin/register/update_virtual'

class Transactions::Admin::Register::UpdateVirtual < Transactions::Base
  def self.for(register)
    super(Schemas::Transactions::Admin::Register::UpdateVirtual, register, :authorize, :persist)
  end

  step :validate, with: :'operations.validation'
  step :authorize, with: :'operations.authorization.update'
  step :persist, with: :'operations.action.update'
end
