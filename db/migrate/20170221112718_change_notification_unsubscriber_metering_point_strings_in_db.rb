class ChangeNotificationUnsubscriberMeteringPointStringsInDb < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        ActiveRecord::Base.transaction do
          NotificationUnsubscriber.where(notification_key: 'metering_point.exceeds').update_all(notification_key: 'register.exceeds')
          NotificationUnsubscriber.where(notification_key: 'metering_point.undershoots').update_all(notification_key: 'register.undershoots')
          NotificationUnsubscriber.where(notification_key: 'metering_point.offline').update_all(notification_key: 'register.offline')
        end
      end

      dir.down do
        ActiveRecord::Base.transaction do
          NotificationUnsubscriber.where(notification_key: 'register.exceeds').update_all(notification_key: 'metering_point.exceeds')
          NotificationUnsubscriber.where(notification_key: 'register.undershoots').update_all(notification_key: 'metering_point.undershoots')
          NotificationUnsubscriber.where(notification_key: 'register.offline').update_all(notification_key: 'metering_point.offline')
        end
      end
    end
  end
end
