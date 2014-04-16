class CreateMeteringServiceProviders < ActiveRecord::Migration
  def change
    create_table :metering_service_providers do |t|

      t.string :customer_number
      t.string :contract_number
      t.string :username
      t.string :password

      t.integer :metering_point_id
      t.integer :organization_id

      t.timestamps
    end
    add_index :metering_service_providers, :organization_id
    add_index :metering_service_providers, :metering_point_id
  end
end
