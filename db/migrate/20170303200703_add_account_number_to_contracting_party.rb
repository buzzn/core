class AddAccountNumberToContractingParty < ActiveRecord::Migration
  def change
    add_column :users, :account_number, :string

    add_column :organizations, :account_number, :string
  end
end
