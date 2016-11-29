class AddOldContractToContract < ActiveRecord::Migration
  def change
    add_column :contracts, :old_supplier_name, :string
    add_column :contracts, :old_customer_number, :string
    add_column :contracts, :old_account_number, :string
  end
end
