class CreateElectricitySupplierContracts < ActiveRecord::Migration
  def change
    create_table :electricity_supplier_contracts do |t|

      t.string  :tariff
      t.money   :price
      t.string  :status
      t.decimal :forecast_watt_hour_pa

      t.date    :commissioning
      t.date    :termination

      t.boolean :terms
      t.boolean :confirm_pricing_model
      t.boolean :power_of_attorney

      t.string  :signing_user
      t.string  :customer_number
      t.string  :contract_number

      t.integer :contracting_party_id
      t.integer :metering_point_id
      t.integer :organization_id

      t.timestamps
    end
    add_index :electricity_supplier_contracts, :contracting_party_id
    add_index :electricity_supplier_contracts, :organization_id
    add_index :electricity_supplier_contracts, :metering_point_id
  end
end
