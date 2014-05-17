class CreateElectricitySupplierContracts < ActiveRecord::Migration
  def change
    create_table :electricity_supplier_contracts do |t|
      t.string :customer_number
      t.string :contract_number
      t.decimal :forecast_wh_pa

      t.integer :metering_point_id
      t.integer :organization_id

      t.timestamps
    end
    add_index :electricity_supplier_contracts, :organization_id
    add_index :electricity_supplier_contracts, :metering_point_id
  end
end
