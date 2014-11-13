class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|

      t.string  :manufacturer_name
      t.string  :manufacturer_product_name
      t.string  :manufacturer_product_serialnumber
      t.string  :mode
      t.string  :law
      t.string  :category
      t.string  :shop_link
      t.string  :primary_energy
      t.integer :watt_peak
      t.decimal :watt_hour_pa
      t.date    :commissioning
      t.boolean :mobile, default: false

      t.integer :metering_point_id

      t.timestamps
    end
    add_index :devices, :metering_point_id
  end
end
