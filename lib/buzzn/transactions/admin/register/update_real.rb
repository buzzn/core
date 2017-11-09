require_relative '../register'
require_relative '../../../schemas/transactions/admin/register/update_real'

class Transactions::Admin::Register::UpdateReal < Transactions::Base
  def self.for(register)
    super(Schemas::Transactions::Admin::Register::UpdateReal, register, :authorize, :persist)
  end

  step :validate, with: :'operations.validation'
  step :authorize, with: :'operations.authorization.update'
  step :persist, with: :'operations.action.update'
end
