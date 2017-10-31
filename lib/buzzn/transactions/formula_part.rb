require_relative 'resource'
require_relative '../schemas/transactions/admin/register/create_formula_part'
require_relative '../schemas/transactions/admin/register/update_formula_part'

Buzzn::Transaction.define do |t|

  t.register_step(:retrieve_register) do |input, registers|
    input[:operand] = registers.retrieve(input.delete(:register_id)).object if input[:register_id]
     Dry::Monads.Right(input)
  end

  t.define(:create_formula_part) do
    validate Schemas::Transactions::Admin::Register::CreateFormulaPart
    step :resource, with: :nested_resource
  end

  t.define(:update_formula_part) do
    validate Schemas::Transactions::Admin::Register::UpdateFormulaPart
    step :registers, with: :retrieve_register
    step :resource, with: :update_resource
  end
end
