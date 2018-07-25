require 'buzzn/schemas/constraints/register/base'

class CreateRegisters < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::Register::Base)

  def up
    SCHEMA.up(:registers, self)

    add_column :registers, :type, :string, null: false

    add_belongs_to :registers, :meter, index: true, null: false

    add_belongs_to :groups, :grid_consumption_register, reference: :registers, index: true, null: true
    add_belongs_to :groups, :grid_feeding_register, reference: :registers, index: true, null: true

    add_foreign_key :registers, :meters, name: :fk_registers_meter, column: :meter_id
  end

  def down
    SCHEMA.down(:registers, self)
  end

end
