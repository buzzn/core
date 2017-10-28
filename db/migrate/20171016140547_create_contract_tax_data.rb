require 'buzzn/schemas/support/migration_visitor'
require 'buzzn/schemas/constraints/contract/tax_data'

class CreateContractTaxData < ActiveRecord::Migration

  SCHEMA = Buzzn::Schemas::MigrationVisitor.new(Schemas::Constraints::Contract::TaxData)

  def up
    SCHEMA.up(:contract_tax_data, self)
    add_column :contract_tax_data, :contract_id, :uuid
    add_foreign_key :contract_tax_data, :contracts, name: :fk_contract_tax_datas_contract, null: true, column_name: :contract_id
  end

  def down
    remove_foreign_key :contract_tax_data, column_name: :contract_id
    remove_column :contract_tax_data, :contract_id
    SCHEMA.down(:contract_tax_data, self)
  end
end
