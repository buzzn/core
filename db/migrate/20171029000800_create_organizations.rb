require 'buzzn/schemas/constraints/organization'

class CreateOrganizations < ActiveRecord::Migration

  SCHEMA = Buzzn::Schemas::MigrationVisitor.new(Schemas::Constraints::Organization)

  def up
    SCHEMA.up(:organizations, self)

    add_column :organizations, :slug, :string, null: true, size: 64
    add_column :organizations, :customer_number, :integer, null: true

    add_belongs_to :organizations, :address, index: true, type: :uuid, null: true
    add_belongs_to :organizations, :legal_representation, references: :persons, index: true, type: :uuid, null: true
    add_belongs_to :organizations, :contact, references: :persons, index: true, type: :uuid, null: true

    add_foreign_key :organizations, :addresses, name: :fk_organizations_address
    add_foreign_key :organizations, :persons, column: :legal_representation_id, name: :fk_organizations_legal_representation
    add_foreign_key :organizations, :persons, column: :contact_id, name: :fk_organizations_contact
    add_foreign_key :organizations, :customer_numbers, name: :fk_organizations_customer_number, column: :customer_number
  end

  def down
    remove_foreign_key :organizations, :addresses, name: :fk_organizations_address
    remove_foreign_key :organizations, :persons, column: :legal_representation_id, name: :fk_organizations_legal_representation
    remove_foreign_key :organizations, :persons, column: :contact_id, name: :fk_organizations_contact

    SCHEMA.down(:organizations, self)
  end
end
