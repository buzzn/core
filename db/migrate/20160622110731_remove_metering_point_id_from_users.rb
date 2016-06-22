class RemoveMeteringPointIdFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :metering_point_id, :string
  end

  def down
    add_column :users, :metering_point_id, :string
  end
end
