class DropCoreTables < ActiveRecord::Migration
  def change
    drop_table :bank_accounts

    add_column :contracts, :register_id, :uuid, null: true
    add_column :devices, :register_id, :uuid, null: true
  end
end
