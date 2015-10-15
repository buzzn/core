class PushNotificationWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :dead => false

  def perform(user_id, type, header, message, duration)
    Pusher.trigger("user_#{user_id}", 'new_notification', :type => type, :header => header, :message => message, :duration => duration)
  end
end