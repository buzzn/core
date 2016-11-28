class CreateDiscovergyBroker < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :discovergy_brokers, id: :uuid do |t|
      t.string :mode, null: false
      t.string :external_id, null: false
      t.string :encrypted_provider_login, null: false
      t.string :encrypted_provider_password, null: false
      t.string :encrypted_provider_token_key
      t.string :encrypted_provider_token_secret
      t.references :resource, polymorphic: true, type: :uuid, index: {name: 'index_discovergy_brokers_resources'}, null: false
      t.timestamps
    end
    add_index :discovergy_brokers, [:mode, :resource_id, :resource_type], unique: true, name: 'index_discovergy_brokers'
  end
end
