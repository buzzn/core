require 'buzzn/schemas/support/migration_visitor'
require 'buzzn/schemas/contract_tax_data_constraints'
class CreateContractTaxDataTable < ActiveRecord::Migration

  SCHEMA = Buzzn::Schemas::MigrationVisitor.new(Schemas::Constraints::Contract::TaxData)

  def up
    SCHEMA.up(:contract_tax_datas, self)
    add_column :contract_tax_datas, :contract_id, :uuid
    add_foreign_key :contract_tax_datas, :contracts, name: :fk_contract_tax_datas_contract, null: true, column_name: :contract_id
  end

  def down
    remove_foreign_key :contract_tax_datas, column_name: :contract_id
    remove_column :contract_tax_datas, :contract_id
    SCHEMA.down(:contract_tax_datas, self)
  end
end
