class CreateDashboardMeteringPoints < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :dashboard_metering_points, id: :uuid do |t|
      t.boolean :displayed, default: false

      t.belongs_to :dashboard, type: :uuid
      t.belongs_to :metering_point, type: :uuid

      t.timestamps null: false
    end
    add_index :dashboard_metering_points, :dashboard_id
    add_index :dashboard_metering_points, :metering_point_id
  end
end
