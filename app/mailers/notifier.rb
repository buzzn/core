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

  def send_email_removed_from_metering_point(receiver, sender, metering_point)
    @receiver = receiver
    @sender = sender
    @metering_point = metering_point
    mail(to: @receiver.email, subject: 'buzzn: ' + t('user_removed_you_from_metering_point', username: @sender.name, metering_point_name: @metering_point.name))
  end

  def send_email_new_group_metering_point_request(receiver, sender, metering_point, group, mode)
    @receiver = receiver
    @sender = sender
    @metering_point = metering_point
    @mode = mode
    @group = group
    if @mode == "request"
      mail(to: @receiver.email, subject: 'buzzn: ' + t('new_group_metering_point_request'))
    else
      mail(to: @receiver.email, subject: 'buzzn: ' + t('new_group_metering_point_invitation'))
    end
  end

  def send_email_accepted_group_metering_point_request(receiver, sender, metering_point, group, mode)
    @receiver = receiver
    @sender = sender
    @metering_point = metering_point
    @mode = mode
    @group = group
    if @mode == "request"
      mail(to: @receiver.email, subject: 'buzzn: ' + t('accepted_group_metering_point_request'))
    else
      mail(to: @receiver.email, subject: 'buzzn: ' + t('accepted_group_metering_point_invitation'))
    end
  end

  def send_email_rejected_group_metering_point_request(receiver, sender, metering_point, group, mode)
    @receiver = receiver
    @sender = sender
    @metering_point = metering_point
    @mode = mode
    @group = group
    if @mode == "request"
      mail(to: @receiver.email, subject: 'buzzn: ' + t('rejected_group_metering_point_request'))
    else
      mail(to: @receiver.email, subject: 'buzzn: ' + t('rejected_group_metering_point_invitation'))
    end
  end

  def send_email_metering_point_exceeds_or_undershoots(receiver, metering_point, mode)
    @receiver = receiver
    @metering_point = metering_point
    @mode = mode
    if @mode == 'exceeds'
      mail(to: @receiver.email, subject: 'buzzn: ' + t('metering_point_exceeded_max_watt', @metering_point.max_watt))
    else
      mail(to: @receiver.email, subject: 'buzzn: ' + t('metering_point_undershot_min_watt', @metering_point.min_watt))
    end
  end

  def send_email_new_comment(receiver, sender, commentable, message)
    @receiver = receiver
    @sender = sender
    @commentable = commentable
    @message = message
    mail(to: @receiver.email, subject: 'buzzn: ' + t('new_comment'))
  end

end
