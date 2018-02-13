class CreateDevices < ActiveRecord::Migration

  def change
    create_table :devices do |t|
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

      t.belongs_to :metering_point

      t.timestamps null: false
    end
    add_index :devices, :metering_point_id
    add_column :devices, :register_id, :integer, null: true
  end

end
