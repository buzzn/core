class ChangeColumn < ActiveRecord::Migration
  def up
    enable_extension 'uuid-ossp'
    remove_column :users, :invited_by_id
    add_column :users, :invited_by_id, :uuid
  end

  def down
    remove_column :users, :invited_by_id
    add_column :users, :invited_by_id
  end
end
