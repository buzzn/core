require 'buzzn/schemas/support/migration_visitor'
class CreatePersonTable < ActiveRecord::Migration

  SCHEMA = Buzzn::Schemas::MigrationVisitor.new(:create_person)

  def up
    SCHEMA.up(:persons, self)
    add_index :persons, [:first_name, :last_name, :email]
  end

  def down
    remove_index :persons, [:first_name, :last_name, :email]
    SCHEMA.down(:persons, self)
  end
end
