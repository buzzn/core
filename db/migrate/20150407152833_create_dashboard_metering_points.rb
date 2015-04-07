class CreateDashboardMeteringPoints < ActiveRecord::Migration
  def change
    create_table :dashboard_metering_points do |t|
      t.boolean :displayed, default: false

      t.integer :dashboard_id
      t.integer :metering_point_id

      t.timestamps null: false
    end
  end
end
