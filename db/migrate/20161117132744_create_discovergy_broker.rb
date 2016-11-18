class CreateDiscovergyBroker < ActiveRecord::Migration
  def change
    create_table :discovergy_brokers, id:false do |t|
      t.string :mode, null: false
      t.string :external_id, null: false
      t.string :provider_login, null: false
      t.string :provider_password, null: false
      t.references :resource, polymorphic: true, index: true, null: false
      t.timestamps
    end
    add_index :discovergy_brokers, [:mode, :resource_id, :resource_type], unique: true, name: 'index_discovergy_brokers'
  end
end
