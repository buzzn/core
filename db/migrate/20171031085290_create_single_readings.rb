require 'buzzn/schemas/support/migration_visitor'
require 'buzzn/schemas/constraints/reading/single'

class CreateSingleReadings < ActiveRecord::Migration

  SCHEMA = Buzzn::Schemas::MigrationVisitor.new(Schemas::Constraints::Reading::Single)

  def up
    SCHEMA.up(:readings, self)

    add_belongs_to :readings, :register, type: :uuid, index: true, null: false

    add_foreign_key :readings, :registers, name: :fk_readings_register

    add_index :readings, [:register_id, :date, :reason], unique: true
  end

  def down
    remove_index :readings, [:register_id, :date, :reason]
    remove_reference :readings, :register
    SCHEMA.down(:readings, self)
  end
end
