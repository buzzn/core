class CreateElectricitySupplierContracts < ActiveRecord::Migration
  def change
    create_table :electricity_supplier_contracts do |t|
      
      t.string :customer_number
      t.string :contract_number

      t.integer :electricity_supplier_id
      t.integer :meter_id

      t.timestamps
    end
  end
end
