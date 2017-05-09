class ChangeContractNumber < ActiveRecord::Migration
  def up
    remove_column :contracts, :contract_number, :string
    add_column :contracts, :contract_number, :integer
    add_column :contracts, :contract_number_addition, :integer
    add_index :contracts, [:contract_number, :contract_number_addition], :unique => true, name: 'index_contract_number_and_its_addition'
    add_index :contracts, :contract_number
  end

  def down
    add_column :contracts, :contract_number, :string
    remove_column :contracts, :contract_number, :integer
    remove_column :contracts, :contract_number_addition, :integer
    remove_index :contracts, [:contract_number, :contract_number_addition], :unique => true, name: 'index_contract_number_and_its_addition'
    remove_index :contracts, :contract_number
  end
end
