class DropContractingPartiesTable < ActiveRecord::Migration
  def up
    #remove_column :contracts, :contract_owner_id, :uuid
    #remove_column :contracts, :contract_beneficiary_id, :uuid
    
    remove_foreign_key :contracts, column: :contractor_id
    remove_foreign_key :contracts, column: :customer_id

    drop_table :contracting_parties
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
