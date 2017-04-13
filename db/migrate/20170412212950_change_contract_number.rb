class ChangeContractNumber < ActiveRecord::Migration
  def up
    remove_column :contracts, :contract_number, :string
    add_column :contracts, :contract_number, :integer
    add_column :contracts, :contract_number_addition, :integer
  end

  def down
    add_column :contracts, :contract_number, :string
    remove_column :contracts, :contract_number, :integer
    remove_column :contracts, :contract_number_addition, :integer
  end
end
