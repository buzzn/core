class CreateGroupUsers < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :group_users, id: :uuid do |t|
      t.belongs_to :user, type: :uuid
      t.belongs_to :group, type: :uuid
      t.timestamps
    end
    add_index :group_users, :group_id
    add_index :group_users, :user_id
  end
end
