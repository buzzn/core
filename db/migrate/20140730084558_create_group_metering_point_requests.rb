class CreateGroupMeteringPointRequests < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :group_metering_point_requests, id: :uuid do |t|
      t.belongs_to :user, type: :uuid
      t.belongs_to :group, type: :uuid
      t.belongs_to :metering_point, type: :uuid
      t.string :status

      t.timestamps
    end
    add_index :group_metering_point_requests, :user_id
    add_index :group_metering_point_requests, :group_id
    add_index :group_metering_point_requests, [:group_id, :user_id]
    add_index :group_metering_point_requests, :metering_point_id
  end
end
