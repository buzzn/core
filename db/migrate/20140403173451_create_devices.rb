class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|

      t.string  :image
      t.string  :name
      t.string  :mode
      t.string  :law
      t.string  :generator_type
      t.string  :manufacturer
      t.string  :manufacturer_product_number
      t.string  :shop_link
      t.string  :primary_energy
      t.decimal :watt_peak
      t.decimal :watt_hour_pa
      t.date    :commissioning
      t.boolean :mobile, default: false


      t.integer :metering_point_id

      t.timestamps
    end
  end
end
