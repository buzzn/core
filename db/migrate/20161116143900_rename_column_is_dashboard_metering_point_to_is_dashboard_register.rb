class RenameColumnIsDashboardMeteringPointToIsDashboardRegister < ActiveRecord::Migration
  def change
    rename_column :registers, :is_dashboard_metering_point, :is_dashboard_register
  end
end
