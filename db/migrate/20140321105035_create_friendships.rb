class CreateFriendships < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :friendships, id: :uuid do |t|
      t.belongs_to :user, type: :uuid, null: false, index: true
      t.belongs_to :friend, type: :uuid, null: false, index: true
      t.string  :status

      t.timestamps
    end
    add_index :friendships, [:friend_id, :user_id]
  end
end
