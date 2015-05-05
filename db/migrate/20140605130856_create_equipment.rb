class CreateEquipment < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :equipment, id: :uuid do |t|

      t.string  :slug
      t.string  :manufacturer_name
      t.string  :manufacturer_product_name
      t.string  :manufacturer_product_serialnumber

      t.string  :device_kind
      t.string  :device_type
      t.string  :ownership
      t.date    :build
      t.date    :calibrated_till
      t.integer :converter_constant

      t.belongs_to :meter, type: :uuid

      t.timestamps
    end
    add_index :equipment, :slug, :unique => true
    add_index :equipment, :meter_id
  end
end
