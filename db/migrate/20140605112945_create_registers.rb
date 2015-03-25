class CreateRegisters < ActiveRecord::Migration
  def change
    create_table :registers do |t|
      t.string  :slug
      t.string  :mode
      t.string  :obis_index
      t.boolean :variable_tariff,   default: false
      t.integer :predecimal_places, default: 8
      t.integer :decimal_places,    default: 2
      t.boolean :virtual,           default: false

      t.integer :metering_point_id

      t.timestamps
    end
    add_index :registers, :slug, :unique => true
    add_index :registers, :metering_point_id
  end
end
