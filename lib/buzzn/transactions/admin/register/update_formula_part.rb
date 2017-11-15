require_relative '../register'
require_relative '../../../schemas/transactions/admin/register/update_formula_part'

class Transactions::Admin::Register::UpdateFormulaPart < Transactions::Base
  def self.for(registers, part)
    new.with_step_args(
      validate: [Schemas::Transactions::Admin::Register::UpdateFormulaPart],
      authorize: [part],
      process: [registers],
      persist: [part]
    )
  end

  step :validate, with: :'operations.validation'
  step :authorize, with: :'operations.authorization.update'
  step :process
  step :persist, with: :'operations.action.update'

  def process(input, registers)
    # adds the right register as operand in the input
    input[:operand] = registers.retrieve(input.delete(:register_id)).object if input[:register_id]
    Dry::Monads.Right(input)
  end
end
