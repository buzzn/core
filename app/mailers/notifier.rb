class Notifier < ActionMailer::Base
  default from: "system@buzzn.net"

  def welcome(user)
    mail(to: user.email, subject: "subject")
  end

  def send_email_notification_meter_offline(user, metering_point)
    @user = user
    @metering_point = metering_point
    mail(to: user.email, subject: t('your_metering_point_is_offline_now', metering_point_name: metering_point.name))
  end

  def send_email_notification_new_friendship_request(receiver, sender)
    @receiver = receiver
    @sender = sender
    mail(to: receiver.email, subject: 'buzzn: ' + t('new_friendship_request_from', sender: sender.name))
  end

  def send_email_notification_accepted_friendship_request(receiver, sender)
    @receiver = receiver
    @sender = sender
    mail(to: receiver.email, subject: 'buzzn: ' + t('accepted_friendship_request'))
  end

  def send_email_notification_new_metering_point_user_request(receiver, sender, metering_point, mode)
    @receiver = receiver
    @sender = sender
    @metering_point = metering_point
    @mode = mode
    if mode == 'request'
      mail(to: @receiver.email, subject: 'buzzn: ' + t('new_metering_point_user_request'))
    else
      mail(to: @receiver.email, subject: 'buzzn: ' + t('new_metering_point_user_invitation'))
    end

  end

  def send_email_notification_accepted_metering_point_user_request(receiver, sender, metering_point, mode)
    @receiver = receiver
    @sender = sender
    @metering_point = metering_point
    @mode = mode
    if mode == 'request'
      mail(to: @receiver.email, subject: 'buzzn: ' + t('new_metering_point_user_request'))
    else
      mail(to: @receiver.email, subject: 'buzzn: ' + t('new_metering_point_user_invitation'))
    end
  end
end
