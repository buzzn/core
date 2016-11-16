class RenameTableGroupMeteringPointRequestsToGroupRegisterRequests < ActiveRecord::Migration
  def change
    rename_index :group_metering_point_requests, "index_group_metering_point_requests_on_group_id_and_user_id", "index_group_register_requests_on_group_id_and_user_id"
    rename_index :group_metering_point_requests, "index_group_metering_point_requests_on_group_id",             "index_group_register_requests_on_group_id"
    rename_index :group_metering_point_requests, "index_group_metering_point_requests_on_metering_point_id",    "index_group_register_requests_on_register_id"
    rename_index :group_metering_point_requests, "index_group_metering_point_requests_on_user_id",              "index_group_register_requests_on_user_id"
    rename_table :group_metering_point_requests, :group_register_requests
  end
end
