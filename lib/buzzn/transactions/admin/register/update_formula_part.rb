require_relative '../register'
require_relative '../../../schemas/transactions/admin/register/update_formula_part'

class Transactions::Admin::Register::UpdateFormulaPart < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update'
  tee :retrieve_operand
  map :persist, with: :'operations.action.update'

  def schema
    Schemas::Transactions::Admin::Register::UpdateFormulaPart
  end

  def retrieve_operand(params:, registers:, **)
    # adds the right register as operand in the input params
    params[:operand] = registers.retrieve(params.delete(:register_id)).object if params[:register_id]
  end

end
