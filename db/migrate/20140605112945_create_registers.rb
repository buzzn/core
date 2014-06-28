class CreateRegisters < ActiveRecord::Migration
  def change
    create_table :registers do |t|
      t.string :obis_index
      t.boolean :variable_tariff, default: false
      t.string :mode
      t.integer :predecimal_places, default: 8
      t.integer :decimal_places, default: 2

      t.integer :meter_id
      t.integer :metering_point_id

      t.timestamps
    end
    add_index :registers, :meter_id
    add_index :registers, :metering_point_id
  end
end
