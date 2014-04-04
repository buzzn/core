class CreatePowerGenerators < ActiveRecord::Migration
  def change
    create_table :power_generators do |t|

      t.string :name
      t.string :law
      t.string :brand
      t.string :primary_energy
      t.decimal :watt_peak
      t.date :commissioning

      t.integer :meter_id

      t.timestamps
    end
    add_index :power_generators, :meter_id
  end
end
