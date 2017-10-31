require 'buzzn/schemas/constraints/register/base'

class CreateRegisters < ActiveRecord::Migration
  SCHEMA = Buzzn::Schemas::MigrationVisitor.new(Schemas::Constraints::Register::Base)

  def up
    SCHEMA.up(:registers, self)

    add_column :registers, :type, :string, null: false

    add_belongs_to :registers, :meter, type: :uuid, index: true, null: false
    add_belongs_to :registers, :group, reference: :register, type: :uuid, index: true, null: true

    add_foreign_key :registers, :meters, name: :fk_registers_meter
    add_foreign_key :registers, :groups, name: :fk_registers_group

    add_index :registers, [:meter_id, :obis], unique: true
    add_index :registers, [:meter_id, :direction], unique: true
  end

  def down
    SCHEMA.down(:registers, self)
  end
end
