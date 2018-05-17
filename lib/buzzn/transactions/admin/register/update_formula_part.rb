require_relative '../register'
require_relative '../../../schemas/transactions/admin/register/update_formula_part'

class Transactions::Admin::Register::UpdateFormulaPart < Transactions::Base

  def self.for(registers, part)
    new.with_step_args(
      authorize: [part],
      process: [registers],
      persist: [part]
    )
  end

  validate :schema
  step :authorize, with: :'operations.authorization.update'
  step :process
  step :persist, with: :'operations.action.update'

  def schema
    Schemas::Transactions::Admin::Register::UpdateFormulaPart
  end

  def process(input, registers)
    # adds the right register as operand in the input
    input[:operand] = registers.retrieve(input.delete(:register_id)).object if input[:register_id]
    Success(input)
  end

end
