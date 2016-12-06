class AddOldContractToContract < ActiveRecord::Migration
  def change
    rename_column :contracts, :old_electricity_supplier_name, :old_supplier_name
    add_column :contracts, :old_customer_number, :string
    add_column :contracts, :old_account_number, :string
  end
end
