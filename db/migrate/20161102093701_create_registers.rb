class CreateRegisters < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :registers, id: :uuid do |t|
      t.string :obis
      t.string :label
      t.boolean :low_load_ability
      t.integer :digits_before_comma
      t.integer :decimal_digits
      t.boolean :virtual

      t.string :metering_point_id, type: :uuid
      t.string :meter_id, type: :uuid

      t.timestamps null: false
    end
    add_index :registers, :id
    add_index :registers, :metering_point_id
    add_index :registers, :meter_id
    add_index :registers, [:metering_point_id, :meter_id]
    add_index :registers, [:metering_point_id, :meter_id, :id]
  end
end
