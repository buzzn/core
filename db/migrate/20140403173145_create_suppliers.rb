class CreateSuppliers < ActiveRecord::Migration
  def change
    create_table :suppliers do |t|
      t.string :name
      t.string :customer_number
      t.string :contract_number

      t.integer :meter_id
      t.timestamps
    end
  end
end
