require 'buzzn/schemas/support/migration_visitor'
class CreatePersons < ActiveRecord::Migration

  SCHEMA = Buzzn::Schemas::MigrationVisitor.new(Schemas::Constraints::Person)

  def up
    SCHEMA.up(:persons, self)
    add_index :persons, [:first_name, :last_name, :email]
  end

  def down
    remove_index :persons, [:first_name, :last_name, :email]
    SCHEMA.down(:persons, self)
  end
end
