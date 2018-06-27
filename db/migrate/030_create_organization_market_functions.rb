require 'buzzn/schemas/constraints/organization/market_function'

class CreateOrganizationMarketFunctions < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::Organization::MarketFunction)

  def up
    SCHEMA.up(:market_functions, self)

    add_belongs_to :market_functions, :address, index: true, null: true
    add_belongs_to :market_functions, :organization, index: true, null: true
    add_belongs_to :market_functions, :contact_person, references: :persons, index: true, null: true

    add_foreign_key :market_functions, :addresses, name: :fk_market_functions_address
    add_foreign_key :market_functions, :organizations, name: :fk__market_functions_organization
    add_foreign_key :market_functions, :persons, column: :contact_person_id, name: :fk_market_functions_contact_person

    add_index :market_functions, [:market_partner_id], unique: true
    add_index :market_functions, [:organization_id, :function], unique: true, name: :index_market_functions_on_organization_id_function
  end

  def down
    SCHEMA.down(:market_functions, self)
  end

end
