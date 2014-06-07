class CreateMeteringPoints < ActiveRecord::Migration
  def change
    create_table :metering_points do |t|
      t.string  :uid
      t.integer :position
      t.string  :address_addition
      t.string  :mode
      t.string  :voltage_level
      t.date    :regular_reeding
      t.string  :regular_interval

      t.integer :location_id
      t.integer :contract_id
      t.integer :group_id

      t.timestamps
    end
    add_index :metering_points, :location_id
    add_index :metering_points, :contract_id
  end
end
