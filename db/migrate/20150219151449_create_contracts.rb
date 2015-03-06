class CreateContracts < ActiveRecord::Migration
  def change
    create_table :contracts do |t|

      t.string   :mode

      t.string   :tariff
      t.monetize :price
      t.string   :status
      t.integer  :forecast_watt_hour_pa, :limit => 8

      t.date    :commissioning
      t.date    :termination

      t.boolean :terms
      t.boolean :confirm_pricing_model
      t.boolean :power_of_attorney

      t.string  :signing_user
      t.string  :customer_number
      t.string  :contract_number

      t.string :username
      t.string :encrypted_password
      t.string :encrypted_password_salt
      t.string :encrypted_password_iv
      t.boolean :valid_credentials, default: false
      t.boolean :running, default: true

      t.integer :contracting_party_id
      t.integer :metering_point_id
      t.integer :organization_id
      t.integer :group_id

      t.timestamps null: false
    end
    add_index :contracts, :mode
    add_index :contracts, :contracting_party_id
    add_index :contracts, :organization_id
    add_index :contracts, :metering_point_id
    add_index :contracts, :group_id
  end
end