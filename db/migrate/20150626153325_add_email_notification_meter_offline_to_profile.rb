class AddEmailNotificationMeterOfflineToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :email_notification_meter_offline, :boolean, :default => false
  end
end
