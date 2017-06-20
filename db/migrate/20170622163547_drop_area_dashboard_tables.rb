class DropAreaDashboardTables < ActiveRecord::Migration
  def up
    drop_table :areas
    drop_table :dashboards
    drop_table :dashboard_registers
    drop_table :friendships
    drop_table :friendship_requests
    drop_table :group_register_requests
    drop_table :register_user_requests
    drop_table :notification_unsubscribers
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
