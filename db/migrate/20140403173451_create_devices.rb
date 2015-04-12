class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string  :slug
      t.string  :manufacturer_name
      t.string  :manufacturer_product_name
      t.string  :manufacturer_product_serialnumber
      t.string  :image
      t.string  :mode
      t.string  :law
      t.string  :category
      t.string  :shop_link
      t.string  :primary_energy
      t.integer :watt_peak
      t.integer :watt_hour_pa
      t.date    :commissioning
      t.boolean :mobile, default: false
      t.string  :secret_level

      t.integer :metering_point_id

      t.timestamps
    end
    add_index :devices, :slug, :unique => true
    add_index :devices, :metering_point_id
    add_index :devices, :secret_level
  end
end
