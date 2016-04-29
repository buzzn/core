class CreateNotificationUnsubscribers < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :notification_unsubscribers, id: :uuid do |t|
      t.string :notification_key
      t.string :channel

      t.belongs_to :user, type: :uuid
      t.belongs_to :trackable, :polymorphic => true, type: :uuid

      t.timestamps null: false
    end

    add_index :notification_unsubscribers, [:user_id]
    add_index :notification_unsubscribers, [:trackable_id, :trackable_type], name: 'index_noti_unsub_trackable'
    add_index :notification_unsubscribers, [:user_id, :trackable_id, :trackable_type], name: 'index_noti_unsub_user_and_trackable'
    add_index :notification_unsubscribers, [:trackable_id, :trackable_type, :notification_key], name: 'index_noti_unsub_trackable_and_key'
    add_index :notification_unsubscribers, [:user_id, :trackable_id, :trackable_type, :notification_key], name: 'index_noti_unsub_full'
  end
end
