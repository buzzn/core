class CreateFriendshipRequests < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :friendship_requests, id: :uuid do |t|
      t.belongs_to :sender, type: :uuid
      t.belongs_to :receiver, type: :uuid
      t.string  :status

      t.timestamps
    end
    add_index :friendship_requests, :sender_id
    add_index :friendship_requests, :receiver_id
    add_index :friendship_requests, [:receiver_id, :sender_id]
  end
end
