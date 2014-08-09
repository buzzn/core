class CreateMeters < ActiveRecord::Migration
  def change
    create_table :meters do |t|

      t.string :manufacturer_name
      t.string :manufacturer_product_name
      t.string :manufacturer_product_serialnumber

      t.string :image
      t.string :owner
      t.boolean :smart, default: false
      t.string :metering_type
      t.string :meter_size
      t.string :rate
      t.string :mode
      t.string :measurement_capture
      t.string :mounting_method
      t.boolean :virtual
      t.date :build_year
      t.date :calibrated_till

      t.integer :metering_point_id

      t.timestamps
    end
    add_index :meters, :metering_point_id
  end
end
