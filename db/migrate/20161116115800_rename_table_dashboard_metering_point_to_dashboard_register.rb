class RenameTableDashboardMeteringPointToDashboardRegister < ActiveRecord::Migration
  def change
    rename_index :dashboard_metering_points, "index_dashboard_metering_points_on_dashboard_id",      "index_dashboard_registers_on_dashboard_id"
    rename_index :dashboard_metering_points, "index_dashboard_metering_points_on_metering_point_id", "index_dashboard_registers_on_metering_point_id"
    rename_table :dashboard_metering_points, :dashboard_registers
  end
end
