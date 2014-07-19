class CreateEquipment < ActiveRecord::Migration
  def change
    create_table :equipment do |t|


      t.string  :manufacturer_name
      t.string  :manufacturer_product_name
      t.string  :manufacturer_product_serialnumber

      t.string  :image
      t.string  :device_kind
      t.string  :device_type
      t.string  :ownership
      t.date    :build
      t.date    :calibrated_till
      t.integer :converter_constant

      t.integer :meter_id

      t.timestamps
    end
    add_index :equipment, :meter_id
  end
end
