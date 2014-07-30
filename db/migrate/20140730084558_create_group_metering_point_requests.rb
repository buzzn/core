class CreateGroupMeteringPointRequests < ActiveRecord::Migration
  def change
    create_table :group_metering_point_requests do |t|
      t.integer :user_id
      t.integer :group_id
      t.integer :metering_point_id
      t.string :status

      t.timestamps
    end
    add_index :group_metering_point_requests, :user_id
    add_index :group_metering_point_requests, :group_id
    add_index :group_metering_point_requests, [:group_id, :user_id]
    add_index :group_metering_point_requests, :metering_point_id
  end
end
