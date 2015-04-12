class CreateDashboardMeteringPoints < ActiveRecord::Migration
  def change
    create_table :dashboard_metering_points do |t|
      t.boolean :displayed, default: false

      t.integer :dashboard_id
      t.integer :metering_point_id

      t.timestamps null: false
    end
    add_index :dashboard_metering_points, :dashboard_id
    add_index :dashboard_metering_points, :metering_point_id
  end
end
