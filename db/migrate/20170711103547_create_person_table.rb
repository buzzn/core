class CreatePersonTable < ActiveRecord::Migration

  SCHEMA = Buzzn::Validation::MigrationSchemaVisitor.new(:create_person_schema)

  def up
    SCHEMA.up(:people, self)
    add_index :people, [:first_name, :last_name, :email]
  end

  def down
    remove_index :people, [:first_name, :last_name, :email]
    SCHEMA.down(:people, self)
  end
end
