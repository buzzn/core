class CreateContracts < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'

    create_table :contracts, id: :uuid do |t|
      t.string :slug
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

      t.boolean :valid_credentials, default: false
      t.boolean :running, default: true

      t.belongs_to :contracting_party, type: :uuid
      t.belongs_to :metering_point, type: :uuid
      t.belongs_to :organization, type: :uuid
      t.belongs_to :group, type: :uuid

      t.timestamps null: false
    end
    add_index :contracts, :slug, :unique => true
    add_index :contracts, :mode
    add_index :contracts, :contracting_party_id
    add_index :contracts, :organization_id
    add_index :contracts, :metering_point_id
    add_index :contracts, :group_id
  end
end