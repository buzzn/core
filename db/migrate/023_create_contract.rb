require 'buzzn/schemas/support/migration_visitor'
require 'buzzn/schemas/constraints/contract/common'

class CreateContract < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::Contract::Common)

  def up
    SCHEMA.up(:contracts, self)
    add_column :contracts, :type, :string, null: false, limit: 64

    add_belongs_to :contracts, :localpool, reference: :group, null: true, index: true
    add_belongs_to :contracts, :customer_bank_account, reference: :bank_account, null: true, index: true
    add_belongs_to :contracts, :contractor_bank_account, reference: :bank_account, null: true, index: true
    add_belongs_to :contracts, :customer_person, reference: :persons, index: true, null: true
    add_belongs_to :contracts, :customer_organization, reference: :organizations, index: true, null: true
    add_belongs_to :contracts, :contractor_person, reference: :persons, index: true, null: true
    add_belongs_to :contracts, :contractor_organization, reference: :organizations, index: true, null: true
    add_belongs_to :contracts, :market_location, index: true, null: true

    add_foreign_key :contracts, :groups, name: :fk_contracts_localpool, column: :localpool_id
    add_foreign_key :contracts, :market_locations, name: :fk_contracts_market_location, column: :market_location_id
    add_foreign_key :contracts, :bank_accounts, name: :fk_contracts_customer_bank_account, column: :customer_bank_account_id
    add_foreign_key :contracts, :bank_accounts, name: :fk_contracts_contractor_bank_account, column: :contractor_bank_account_id
    add_foreign_key :contracts, :persons, name: :fk_contracts_customer_person, column: :customer_person_id
    add_foreign_key :contracts, :organizations, name: :fk_contracts_customer_organization, column: :customer_organization_id
    add_foreign_key :contracts, :persons, name: :fk_contracts_contractor_person, column: :contractor_person_id
    add_foreign_key :contracts, :organizations, name: :fk_contracts_contractor_organization, column: :contractor_organization_id

    # TODO: move that to a more sane place
    execute 'CREATE EXTENSION IF NOT EXISTS btree_gist'
    execute 'ALTER TABLE contracts ADD CONSTRAINT check_contract_customer CHECK (NOT (customer_person_id IS NOT NULL AND customer_organization_id IS NOT NULL))'
    execute 'ALTER TABLE contracts ADD CONSTRAINT check_contract_contractor CHECK (NOT (contractor_person_id IS NOT NULL AND contractor_organization_id IS NOT NULL))'
    execute 'ALTER TABLE contracts ADD CONSTRAINT one_localpool_processing_per_group EXCLUDE USING gist (localpool_id with =) WHERE (type = \'Contract::LocalpoolProcessing\')'
  end

  def down
    SCHEMA.down(:contracts, self)
  end

end
