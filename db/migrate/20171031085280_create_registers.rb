require 'buzzn/schemas/constraints/register/base'

class CreateRegisters < ActiveRecord::Migration
  SCHEMA = Buzzn::Schemas::MigrationVisitor.new(Schemas::Constraints::Register::Base)

  def up
    SCHEMA.up(:registers, self)

    add_column :registers, :type, :string, null: false
    add_column :registers, :last_observed, :timestamp, null: true

    add_belongs_to :registers, :meter, type: :uuid, index: true, null: false
    add_belongs_to :registers, :group, reference: :register, type: :uuid, index: true, null: true

    add_belongs_to :groups, :grid_consumption_register, reference: :registers, type: :uuid, index: true, null: true
    add_belongs_to :groups, :grid_feeding_register, reference: :registers, type: :uuid, index: true, null: true

    add_foreign_key :registers, :meters, name: :fk_registers_meter
    add_foreign_key :registers, :groups, name: :fk_registers_group

    add_foreign_key :groups, :registers, name: :fk_groups_grid_consumption, column: :grid_consumption_register_id
    add_foreign_key :groups, :registers, name: :fk_groups_grid_feeding, column: :grid_feeding_register_id

    add_index :registers, [:meter_id, :obis], unique: true
    add_index :registers, [:meter_id, :direction], unique: true
  end

  def down
    SCHEMA.down(:registers, self)
  end
end
