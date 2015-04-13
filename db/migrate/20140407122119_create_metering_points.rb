class CreateMeteringPoints < ActiveRecord::Migration
  def change
    create_table :metering_points do |t|
      t.string  :slug
      t.string  :uid
      t.string  :mode
      t.string  :name
      t.string  :image
      t.string  :voltage_level
      t.date    :regular_reeding
      t.string  :regular_interval
      t.boolean :virtual, default: false
      t.boolean :is_dashboard_metering_point, default: false
      t.string  :readable

      t.integer :meter_id
      t.integer :contract_id
      t.integer :group_id

      t.timestamps
    end
    add_index :metering_points, :slug, :unique => true
    add_index :metering_points, :meter_id
    add_index :metering_points, :contract_id
    add_index :metering_points, :group_id
    add_index :metering_points, :readable
  end
end
