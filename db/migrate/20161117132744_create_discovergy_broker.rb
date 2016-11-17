class CreateDiscovergyBroker < ActiveRecord::Migration
  def change
    create_table :discovergy_brokers do |t|
      t.string :mode
      t.string :external_id
      t.string :provider_login
      t.string :provider_password
      t.references :resource, polymorphic: true, index: true
      t.timestamps
    end
  end
end
