class DropCoreTables < ActiveRecord::Migration
  def change
    drop_table :bank_accounts
    drop_table :payments
    drop_table :contract_tax_data

    add_column :contracts, :register_id, :uuid, null: true
    add_column :devices, :register_id, :uuid, null: true
  end
end
