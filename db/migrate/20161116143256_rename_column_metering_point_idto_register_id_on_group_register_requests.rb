class RenameColumnMeteringPointIdtoRegisterIdOnGroupRegisterRequests < ActiveRecord::Migration
  def change
    rename_column :group_register_requests, :metering_point_id, :register_id
  end
end
