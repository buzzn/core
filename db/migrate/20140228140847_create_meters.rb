class CreateMeters < ActiveRecord::Migration
  def change
    create_table :meters do |t|

      t.string  :manufacturer_name
      t.string  :manufacturer_product_number
      t.string  :manufacturer_meter_number
      t.boolean :virtual, default: false

      t.integer :metering_point_id

      t.timestamps
    end
    add_index :meters, :metering_point_id
  end
end
