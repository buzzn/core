require 'buzzn/schemas/constraints/register/formula_part'

class CreateFormulaParts < ActiveRecord::Migration

  SCHEMA = Buzzn::Schemas::MigrationVisitor.new(Schemas::Constraints::Register::FormulaPart)

  def up
    SCHEMA.up(:formula_parts, self)

    add_belongs_to :formula_parts, :register, type: :uuid, index: true, null: false
    add_belongs_to :formula_parts, :operand, reference: :register, type: :uuid, index: true, null: false

    add_foreign_key :formula_parts, :registers, name: :fk_formula_parts_register
    add_foreign_key :formula_parts, :registers, name: :fk_formula_parts_operand, column: :operand_id
  end

  def down
    SCHEMA.down(:formula_parts, self)
  end
end
