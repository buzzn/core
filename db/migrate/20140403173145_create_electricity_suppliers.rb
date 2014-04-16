class CreateElectricitySuppliers < ActiveRecord::Migration
  def change
    create_table :electricity_suppliers do |t|
      t.string :name
      t.string :customer_number
      t.string :contract_number

      t.integer :metering_point_id
      t.integer :organization_id
      t.timestamps
    end
    add_index :electricity_suppliers, :organization_id
    add_index :electricity_suppliers, :metering_point_id
  end
end
