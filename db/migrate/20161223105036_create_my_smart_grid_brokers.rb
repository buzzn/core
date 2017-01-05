class CreateMySmartGridBrokers < ActiveRecord::Migration
  def change
    rename_index :discovergy_brokers, "index_discovergy_brokers_resources", "index_brokers_resources"
    rename_index :discovergy_brokers, "index_discovergy_brokers", "index_brokers"
    rename_table :discovergy_brokers, :brokers
    add_column :brokers, :type, :string, null: false
  end
end
