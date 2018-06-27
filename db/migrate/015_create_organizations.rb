require 'buzzn/schemas/constraints/organization/base'

class CreateOrganizations < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::Organization::Base)

  def up
    SCHEMA.up(:organizations, self)

    add_column :organizations, :type, :string, null: false
    add_column :organizations, :slug, :string, null: false, limit: 64
    add_column :organizations, :customer_number, :integer, null: true

    add_belongs_to :organizations, :address, index: true, null: true
    add_belongs_to :organizations, :legal_representation, references: :persons, index: true, null: true
    add_belongs_to :organizations, :contact, references: :persons, index: true, null: true

    add_belongs_to :devices, :electricity_supplier, references: :organizations, index: true, null: true

    add_foreign_key :organizations, :addresses, name: :fk_organizations_address
    add_foreign_key :organizations, :persons, column: :legal_representation_id, name: :fk_organizations_legal_representation
    add_foreign_key :organizations, :persons, column: :contact_id, name: :fk_organizations_contact
    add_foreign_key :organizations, :customer_numbers, name: :fk_organizations_customer_number, column: :customer_number

    add_foreign_key :devices, :organizations, name: :fk_devices_electricity_supplier, column: :electricity_supplier_id

    add_index :organizations, [:slug], unique: true
  end

  def down
    remove_foreign_key :organizations, :addresses, name: :fk_organizations_address
    remove_foreign_key :organizations, :persons, column: :legal_representation_id, name: :fk_organizations_legal_representation
    remove_foreign_key :organizations, :persons, column: :contact_id, name: :fk_organizations_contact

    SCHEMA.down(:organizations, self)
  end

end
