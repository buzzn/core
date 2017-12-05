class DropCoreTables < ActiveRecord::Migration
  def change
    drop_table :tariffs
    drop_table :billings
    drop_table :billing_cycles
    drop_table :formula_parts
    drop_table :registers
    drop_table :meters
    drop_table :groups
    drop_table :bank_accounts
    drop_table :organizations
    drop_table :users
    drop_table :profiles
    drop_table :addresses
    drop_table :roles
    drop_table :brokers
  end
end
