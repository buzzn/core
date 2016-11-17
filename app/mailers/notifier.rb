class Notifier < ActionMailer::Base
  default from: "system@buzzn.net"

  def welcome(user)
    mail(to: user.email, subject: "subject")
  end

  def send_email_completed_registration(user)
    return user.profile.nil?
    @user = user
    mail(to: @user.email, subject: t('welcome_to_the_buzzn_community'))
  end



  def send_email_notification_new_friendship_request(receiver, sender)
    return receiver.profile.nil?
    return sender.profile.nil?
    @receiver = receiver
    @sender = sender
    mail(to: receiver.email, subject: 'buzzn: ' + t('new_friendship_request_from', sender: sender.name))
  end

  def send_email_notification_accepted_friendship_request(receiver, sender)
    return receiver.profile.nil?
    return sender.profile.nil?
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
    return receiver.profile.nil?
    return sender.profile.nil?
    @receiver = receiver
    @sender = sender
    mail(to: receiver.email, subject: 'buzzn: ' + t('cancelled_friendship'))
  end





  def send_email_notification_new_register_user_request(receiver, sender, register, mode)
    return receiver.profile.nil?
    return sender.profile.nil?
    @receiver = receiver
    @sender = sender
    @register = register
    @mode = mode
    if mode == 'request'
      mail(to: @receiver.email, subject: 'buzzn: ' + t('new_register_user_request'))
    else
      mail(to: @receiver.email, subject: 'buzzn: ' + t('new_register_user_invitation'))
    end
  end

  def send_email_notification_new_register_user_membership(receiver, sender, register)
    return receiver.profile.nil?
    return sender.profile.nil?
    @receiver = receiver
    @sender = sender
    @register = register
    mail(to: @receiver.email, subject: 'buzzn: ' + t('new_register_user_membership'))
  end

  def send_email_notification_rejected_register_user_request(receiver, sender, register, mode)
    @receiver = receiver
    @sender = sender
    @register = register
    @mode = mode
    if mode == 'request'
      mail(to: @receiver.email, subject: 'buzzn: ' + t('rejected_register_user_request'))
    else
      mail(to: @receiver.email, subject: 'buzzn: ' + t('rejected_register_user_invitation'))
    end
  end

  def send_email_notification_cancelled_register_user_membership(receiver, sender, register)
    return receiver.profile.nil?
    return sender.profile.nil?
    @receiver = receiver
    @sender = sender
    @register = register
    mail(to: @receiver.email, subject: 'buzzn: ' + t('cancelled_register_user_membership'))
  end








  def send_email_new_group_register_request(receiver, sender, register, group, mode)
    return receiver.profile.nil?
    return sender.profile.nil?
    @receiver = receiver
    @sender = sender
    @register = register
    @mode = mode
    @group = group
    if @mode == "request"
      mail(to: @receiver.email, subject: 'buzzn: ' + t('new_group_register_request'))
    else
      mail(to: @receiver.email, subject: 'buzzn: ' + t('new_group_register_invitation'))
    end
  end

  def send_email_rejected_group_register_request(receiver, sender, register, group, mode)
    return receiver.profile.nil?
    return sender.profile.nil?
    @receiver = receiver
    @sender = sender
    @register = register
    @mode = mode
    @group = group
    if @mode == "request"
      mail(to: @receiver.email, subject: 'buzzn: ' + t('rejected_group_register_request'))
    else
      mail(to: @receiver.email, subject: 'buzzn: ' + t('rejected_group_register_invitation'))
    end
  end

  def send_email_new_group_register_membership(receiver, sender, register, group)
    return receiver.profile.nil?
    return sender.profile.nil?
    @receiver = receiver
    @sender = sender
    @register = register
    @group = group
    mail(to: @receiver.email, subject: 'buzzn: ' + t('new_group_register_membership'))
  end

  def send_email_cancelled_group_register_membership(receiver, sender, register, group)
    return receiver.profile.nil?
    return sender.profile.nil?
    @receiver = receiver
    @sender = sender
    @register = register
    @group = group
    mail(to: @receiver.email, subject: 'buzzn: ' + t('cancelled_group_register_membership'))
  end






  def send_email_register_exceeds_or_undershoots(receiver, register, mode)
    return receiver.profile.nil?
    @receiver = receiver
    @register = register
    @mode = mode
    if @mode == 'exceeds'
      mail(to: @receiver.email, subject: 'buzzn: ' + t('register_exceeded_max_watt', register_name: @register.name, max_watt: @register.max_watt))
    else
      mail(to: @receiver.email, subject: 'buzzn: ' + t('register_undershot_min_watt', register_name: @register.name, min_watt: @register.min_watt))
    end
  end

  def send_email_notification_meter_offline(user, register)
    return user.profile.nil?
    @user = user
    @register = register
    mail(to: user.email, subject: t('your_register_is_offline_now', register_name: register.name))
  end




  def send_email_accepted_platform_invitation(receiver, sender)
    return receiver.profile.nil?
    return sender.profile.nil?
    @receiver = receiver
    @sender = sender
    mail(to: @receiver.email, subject: 'buzzn: ' + t('accepted_platform_invitation'))
  end




  def send_email_appointed_register_manager(receiver, sender, register)
    return receiver.profile.nil?
    return sender.profile.nil?
    @receiver = receiver
    @sender = sender
    @register = register
    mail(to: @receiver.email, subject: 'buzzn: ' + t('appointed_register_manager'))
  end

  def send_email_appointed_group_manager(receiver, sender, group)
    return receiver.profile.nil?
    return sender.profile.nil?
    @receiver = receiver
    @sender = sender
    @group = group
    mail(to: @receiver.email, subject: 'buzzn: ' + t('appointed_group_manager'))
  end





  def send_email_new_comment(receiver, sender, commentable, message)
    return receiver.profile.nil?
    return sender.profile.nil?
    @receiver = receiver
    @sender = sender
    @commentable = commentable
    @message = message
    mail(to: @receiver.email, subject: 'buzzn: ' + t('new_comment'))
  end

  def send_email_comment_liked(receiver, sender, message)
    return receiver.profile.nil?
    return sender.profile.nil?
    @receiver = receiver
    @sender = sender
    @message = message
    mail(to: @receiver.email, subject: 'buzzn: ' + t('user_liked_your_comment', username: @sender.name))
  end



  def send_email_to_user_variable_content(receiver, subject, message)
    return receiver.profile.nil?
    @receiver = receiver
    @subject = subject
    @message = message
    mail(to: @receiver.email, subject: @subject)
  end



  def send_email_removed_user_from_conversation(receiver, sender)
    return receiver.profile.nil?
    return sender.profile.nil?
    @receiver = receiver
    @sender = sender
    mail(to: @receiver.email, subject: 'buzzn: ' + t('user_removed_from_conversation'))
  end

end
