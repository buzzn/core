class BadgeNotificationCreationWorker
  include Sidekiq::Worker

  def perform(users, activity)
    users.each do |user|
      BadgeNotification.create(user: user, activity: activity)
    end
  end
end