class CreateMetersOld < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :meters, id: :uuid do |t|
      t.string :slug
      t.string :manufacturer_name
      t.string :manufacturer_product_name
      t.string :manufacturer_product_serialnumber
      t.string :owner
      t.string :metering_type
      t.string :meter_size
      t.string :rate
      t.string :mode
      t.string :image
      t.string :measurement_capture
      t.string :mounting_method
      t.date :build_year
      t.date :calibrated_till
      t.boolean :smart, default: false
      t.boolean :online, default: false
      t.boolean :pull_readings, default: true
      t.boolean :init_first_reading, default: false
      t.boolean :init_reading, default: false
      t.string  :ancestry

      t.timestamps
    end
    add_index :meters, :slug, :unique => true
    add_index :meters, :ancestry
  end
end
