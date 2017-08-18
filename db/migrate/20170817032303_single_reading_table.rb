class SingleReadingTable < ActiveRecord::Migration

  SCHEMA = Buzzn::Validation::MigrationSchemaVisitor.new(:create_reading_schema)

  def up
    SCHEMA.up(:single_readings, self)
    add_reference :single_readings, :register, foreign_key: true, index: true, null: false, type: :uuid
    add_index :single_readings, [:register_id, :date, :reason], unique: true
  end

  def down
    remove_index :single_readings, [:register_id, :date, :reason]
    remove_reference :single_readings, :register
    SCHEMA.down(:single_readings, self)
  end
end
