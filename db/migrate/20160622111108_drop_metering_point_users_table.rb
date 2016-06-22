class DropMeteringPointUsersTable < ActiveRecord::Migration
  def up
    drop_table :metering_point_users
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
