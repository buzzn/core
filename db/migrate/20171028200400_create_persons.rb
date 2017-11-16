require 'buzzn/schemas/support/migration_visitor'
require 'buzzn/schemas/constraints/person'

class CreatePersons < ActiveRecord::Migration

  SCHEMA = Buzzn::Schemas::MigrationVisitor.new(Schemas::Constraints::Person)

  def up
    SCHEMA.up(:persons, self)

    add_column :persons, :image, :string, length: 64, null: true
    add_column :persons, :customer_number, :integer, null: true

    add_belongs_to :persons, :address, index: true, type: :uuid, null: true

    add_foreign_key :persons, :addresses, name: :fk_organizations_address
    add_foreign_key :persons, :customer_numbers, name: :fk_persons_customer_number, column: :customer_number
    add_index :persons, [:first_name, :last_name, :email]
  end

  def down
    remove_column :persons, :customer_number, :integer, null: true
    remove_foreign_key :persons, :customer_numbers, name: :fk_persons_customer_number, column: :customer_number
    remove_index :persons, [:first_name, :last_name, :email]
    SCHEMA.down(:persons, self)
  end
end
