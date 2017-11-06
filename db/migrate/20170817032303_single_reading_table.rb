require 'buzzn/schemas/support/migration_visitor'
class SingleReadingTable < ActiveRecord::Migration

  SCHEMA = Buzzn::Schemas::MigrationVisitor.new(:create_reading)

  def up
    SCHEMA.up(:readings, self)
    add_reference :readings, :register, foreign_key: true, index: true, null: false, type: :uuid
    add_index :readings, [:register_id, :date, :reason], unique: true
  end

  def down
    remove_index :readings, [:register_id, :date, :reason]
    remove_reference :readings, :register
    SCHEMA.down(:readings, self)
  end
end