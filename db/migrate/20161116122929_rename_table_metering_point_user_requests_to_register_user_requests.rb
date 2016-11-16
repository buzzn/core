class RenameTableMeteringPointUserRequestsToRegisterUserRequests < ActiveRecord::Migration
  def change
    rename_index :metering_point_user_requests, "index_metering_point_user_requests_on_metering_point_id", "index_register_user_requests_on_register_id"
    rename_index :metering_point_user_requests, "index_metering_point_user_requests_on_mode", "index_register_user_requests_on_mode"
    rename_index :metering_point_user_requests, "index_metering_point_user_requests_on_user_id", "index_register_user_requests_on_user_id"
    rename_table :metering_point_user_requests, :register_user_requests
  end
end
