class RemoveGroupUsers < ActiveRecord::Migration
  def up
    drop_table :group_users
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
