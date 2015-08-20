class AddModeToGroupMeteringPointRequests < ActiveRecord::Migration
  def change
    add_column :group_metering_point_requests, :mode, :string
  end
end
