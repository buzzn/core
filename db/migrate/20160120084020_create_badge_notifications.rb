class CreateBadgeNotifications < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :badge_notifications, id: :uuid do |t|
      t.boolean :read_by_user, default: false
      t.belongs_to :user, type: :uuid
      t.belongs_to :activity, type: :uuid
      t.timestamps null: false
    end
    add_index :badge_notifications, :user_id
    add_index :badge_notifications, :activity_id
    add_index :badge_notifications, :read_by_user
  end
end
