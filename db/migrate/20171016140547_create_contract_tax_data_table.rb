require 'buzzn/schemas/support/migration_visitor'
require 'buzzn/schemas/contract_tax_data_constraints'
class CreateContractTaxDataTable < ActiveRecord::Migration

  SCHEMA = Buzzn::Schemas::MigrationVisitor.new(ContractTaxDataContraints)

  def up
    SCHEMA.up(:contract_tax_data_tables, self)
  end

  def down
    SCHEMA.down(:contract_tax_data_tables, self)
  end
end
