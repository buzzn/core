class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|

      t.string  :image
      t.string  :name
      t.string  :law
      t.string  :manufacturer
      t.string  :manufacturer_product_number
      t.string  :shop_link
      t.string  :primary_energy
      t.decimal :watt_peak
      t.date    :commissioning

      t.timestamps
    end
  end
end
