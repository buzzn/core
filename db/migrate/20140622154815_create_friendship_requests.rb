class CreateFriendshipRequests < ActiveRecord::Migration
  def change
    create_table :friendship_requests do |t|
      t.integer :sender_id
      t.integer :receiver_id
      t.string  :status

      t.timestamps
    end
    add_index :friendship_requests, :sender_id
    add_index :friendship_requests, :receiver_id
    add_index :friendship_requests, [:receiver_id, :sender_id]
  end
end
