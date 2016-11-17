class RenameColumnMeteringPointIdtoRegisterIdOnRegisterUserRequests < ActiveRecord::Migration
  def change
    rename_column :register_user_requests, :metering_point_id, :register_id
  end
end
