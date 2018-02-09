require 'buzzn/schemas/constraints/organization_market_function'

class CreateOrganizationMarketFunctions < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::OrganizationMarketFunction)

  def up
    SCHEMA.up(:organization_market_functions, self)

    add_belongs_to :organization_market_functions, :address, index: true, type: :uuid, null: true
    add_belongs_to :organization_market_functions, :organization, index: true, type: :uuid, null: true
    add_belongs_to :organization_market_functions, :contact_person, references: :persons, index: true, type: :uuid, null: true

    add_foreign_key :organization_market_functions, :addresses, name: :fk_organization_market_functions_address
    add_foreign_key :organization_market_functions, :organizations, name: :fk_organization_market_functions_organization
    add_foreign_key :organization_market_functions, :persons, column: :contact_person_id, name: :fk_organization_market_functions_contact_person

    add_index :organization_market_functions, [:market_partner_id], unique: true
    add_index :organization_market_functions, [:organization_id, :function], unique: true, name: :index_market_functions_on_organization_id_function
  end

  def down

    SCHEMA.down(:organization_market_functions, self)
  end

end
