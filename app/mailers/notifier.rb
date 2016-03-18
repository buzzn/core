class Notifier < ActionMailer::Base
  default from: "system@buzzn.net"

  def welcome(user)
    mail(to: user.email, subject: "subject")
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

  def send_email_notification_rejected_friendship_request(receiver, sender)
    @receiver = receiver
    @sender = sender
    mail(to: receiver.email, subject: 'buzzn: ' + t('rejected_friendship_request'))
  end

  def send_email_notification_cancelled_friendship(receiver, sender)
    @receiver = receiver
    @sender = sender
    mail(to: receiver.email, subject: 'buzzn: ' + t('cancelled_friendship'))
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

  def send_email_notification_new_metering_point_user_membership(receiver, sender, metering_point)
    @receiver = receiver
    @sender = sender
    @metering_point = metering_point
    mail(to: @receiver.email, subject: 'buzzn: ' + t('new_metering_point_user_membership'))
  end

  def send_email_notification_rejected_metering_point_user_request(receiver, sender, metering_point, mode)
    @receiver = receiver
    @sender = sender
    @metering_point = metering_point
    @mode = mode
    if mode == 'request'
      mail(to: @receiver.email, subject: 'buzzn: ' + t('rejected_metering_point_user_request'))
    else
      mail(to: @receiver.email, subject: 'buzzn: ' + t('rejected_metering_point_user_invitation'))
    end
  end

  def send_email_notification_cancelled_metering_point_user_membership(receiver, sender, metering_point)
    @receiver = receiver
    @sender = sender
    @metering_point = metering_point
    mail(to: @receiver.email, subject: 'buzzn: ' + t('cancelled_metering_point_user_membership'))
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

  def send_email_new_group_metering_point_membership(receiver, sender, metering_point, group)
    @receiver = receiver
    @sender = sender
    @metering_point = metering_point
    @group = group
    mail(to: @receiver.email, subject: 'buzzn: ' + t('new_group_metering_point_membership'))
  end

  def send_email_cancelled_group_metering_point_membership(receiver, sender, metering_point, group)
    @receiver = receiver
    @sender = sender
    @metering_point = metering_point
    @group = group
    mail(to: @receiver.email, subject: 'buzzn: ' + t('cancelled_group_metering_point_membership'))
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

  def send_email_notification_meter_offline(user, metering_point)
    @user = user
    @metering_point = metering_point
    mail(to: user.email, subject: t('your_metering_point_is_offline_now', metering_point_name: metering_point.name))
  end




  def send_email_accepted_platform_invitation(receiver, sender)
    @receiver = receiver
    @sender = sender
    mail(to: @receiver.email, subject: 'buzzn: ' + t('accepted_platform_invitation'))
  end




  def send_email_appointed_metering_point_manager(receiver, sender, metering_point)
    @receiver = receiver
    @sender = sender
    @metering_point = metering_point
    mail(to: @receiver.email, subject: 'buzzn: ' + t('appointed_metering_point_manager'))
  end

  def send_email_appointed_group_manager(receiver, sender, group)
    @receiver = receiver
    @sender = sender
    @group = group
    mail(to: @receiver.email, subject: 'buzzn: ' + t('appointed_group_manager'))
  end





  def send_email_new_comment(receiver, sender, commentable, message)
    @receiver = receiver
    @sender = sender
    @commentable = commentable
    @message = message
    mail(to: @receiver.email, subject: 'buzzn: ' + t('new_comment'))
  end

  def send_email_comment_liked(receiver, sender, message)
    @receiver = receiver
    @sender = sender
    @message = message
    mail(to: @receiver.email, subject: 'buzzn: ' + t('user_liked_your_comment', username: @sender.name))
  end



  def send_email_to_user_variable_content(receiver, subject, message)
    @receiver = receiver
    @subject = subject
    @message = message
    mail(to: @receiver.email, subject: @subject)
  end

end
