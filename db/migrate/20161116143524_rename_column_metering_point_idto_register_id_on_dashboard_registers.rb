class RenameColumnMeteringPointIdtoRegisterIdOnDashboardRegisters < ActiveRecord::Migration
  def change
    rename_column :dashboard_registers, :metering_point_id, :register_id
  end
end
