class RenameColumnMeteringPointIdtoRegisterIdOnDevices < ActiveRecord::Migration
  def change
    rename_column :devices, :metering_point_id, :register_id
  end
end
