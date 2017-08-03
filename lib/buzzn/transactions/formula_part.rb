require_relative 'resource'
Buzzn::Transaction.define do |t|
  t.register_validation(:create_formula_part_schema) do
    required(:operator).value(included_in?: Register::FormulaPart::OPERATORS)
    required(:register_id).filled(:str?)
  end

  t.register_validation(:update_formula_part_schema) do
    required(:updated_at).filled(:date_time?)
    optional(:operator).value(included_in?: Register::FormulaPart::OPERATORS)
    optional(:register_id).filled(:str?)
  end

  t.register_step(:retrieve_register) do |input, registers|
    input[:operand] = registers.retrieve(input.delete(:register_id)).object if input[:register_id]
     Dry::Monads.Right(input)
  end

  t.define(:create_formula_part) do
    validate :create_formula_part_schema
    step :resource, with: :nested_resource
  end

  t.define(:update_formula_part) do
    validate :update_formula_part_schema
    step :registers, with: :retrieve_register
    step :resource, with: :update_resource
  end
end
