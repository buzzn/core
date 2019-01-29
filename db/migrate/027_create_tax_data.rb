require 'buzzn/schemas/support/migration_visitor'
require 'buzzn/schemas/constraints/contract/tax_data'

class CreateTaxData < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::Contract::TaxData)

  def up
    SCHEMA.up(:contract_tax_data, self)
    add_belongs_to :contract_tax_data, :contract, index: true
    add_foreign_key :contract_tax_data, :contracts, name: :fk_tax_data_contract, on_delete: :cascade
  end

  def down
    remove_reference :contract_tax_data, :contract
    remove_foreign_key :contract_tax_data, :contracts, name: :fk_tax_data_contract
    SCHEMA.down(:contract_tax_data, self)
  end

end
