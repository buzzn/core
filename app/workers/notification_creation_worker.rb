class NotificationCreationWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers
  sidekiq_options :retry => false, :dead => false

  # This worker gets triggered after a PublicActivity::Activity is created in the database
  # For each activity the worker decides which users get which notification dependent on
  # the key of the activity
  def perform(activity_id)
    @activity = PublicActivity::Activity.find(activity_id)
    owner = @activity.owner
    email_users = []
    growl_users = []
    badge_users = []
    case @activity.key

    ########## friendship ###########
    when 'friendship_request.create'
      Notifier.send_email_notification_new_friendship_request(@activity.recipient, @activity.owner).deliver_now
      badge_users = [@activity.recipient]
      @activity.recipient.send_notification('info', I18n.t('new_friendship_request'), owner.name, 0, profile_path(owner.profile)) if owner.profile
    when 'friendship.create'
      Notifier.send_email_notification_accepted_friendship_request(@activity.recipient, @activity.owner).deliver_now
      badge_users = (@activity.owner.friends + @activity.recipient.friends + [@activity.recipient] - [owner]).uniq
      @activity.recipient.send_notification('info', I18n.t('accepted_friendship_request'), I18n.t('user_is_your_friend_now', user_name: owner.name), 0, profile_path(owner.profile)) if owner.profile
    when 'friendship_request.reject'
      Notifier.send_email_notification_rejected_friendship_request(@activity.recipient, @activity.owner).deliver_now
      badge_users = [@activity.recipient]
      @activity.recipient.send_notification('info', I18n.t('rejected_friendship_request'), I18n.t('user_rejected_your_friendship_request', user: owner.name), 0, profile_path(owner.profile)) if owner.profile
    when 'friendship.cancel'
      Notifier.send_email_notification_cancelled_friendship(@activity.recipient, @activity.owner).deliver_now
      badge_users = [@activity.recipient]
      @activity.recipient.send_notification('info', I18n.t('cancelled_friendship'), I18n.t('user_cancelled_the_friendship_with_you', user: owner.name), 0, profile_path(owner.profile)) if owner.profile

    # when 'register.create'
    #   users = owner.friends if owner
    # when 'register.destroy'
    #   users = @activity.trackable.involved

    ########## register.membership ###########
    when 'register_user_request.create'
      email_users = @activity.trackable.managers
      email_users.each do |user|
        Notifier.send_email_notification_new_register_user_request(user, owner, @activity.trackable, 'request').deliver_now
      end
      badge_users = email_users
      growl_users = email_users
      growl_users.each do |user|
        user.send_notification('info', I18n.t('new_register_user_request'), I18n.t('user_wants_to_join_your_register', user: owner.name, register: @activity.trackable.name), 0, register_path(@activity.trackable))
      end
    when 'register_user_request.reject'
      email_users = @activity.trackable.managers - [owner] + [@activity.recipient]
      email_users.each do |user|
        Notifier.send_email_notification_rejected_register_user_request(user, owner, @activity.trackable, 'request').deliver_now
      end
      badge_users = email_users
      growl_users = email_users
      growl_users.each do |user|
        user.send_notification('info', I18n.t('rejected_register_user_request'), @activity.trackable.name, 0, register_path(@activity.trackable))
      end
    when 'register_user_invitation.create'
      Notifier.send_email_notification_new_register_user_request(@activity.recipient, owner, @activity.trackable, 'invitation').deliver_now
      badge_users = @activity.trackable.managers + [@activity.recipient] - [owner]
      @activity.recipient.send_notification('info', I18n.t('new_register_user_invitation'), I18n.t('user_invited_you_to_join_the_register', user: owner.name, register: @activity.trackable.name), 0, register_path(@activity.trackable))
    when 'register_user_invitation.reject'
      email_users = @activity.trackable.managers
      email_users.each do |user|
        Notifier.send_email_notification_rejected_register_user_request(user, owner, @activity.trackable, 'invitation').deliver_now
      end
      badge_users = email_users
      growl_users = email_users
      growl_users.each do |user|
        user.send_notification('info', I18n.t('rejected_register_user_invitation'), owner.name, 0, profile_path(owner))
      end
    when 'register_user_membership.create'
      email_users = (@activity.trackable.managers + [owner]).uniq
      email_users.each do |user|
        Notifier.send_email_notification_new_register_user_membership(user, owner, @activity.trackable).deliver_now
      end
      badge_users = @activity.trackable.involved
      growl_users = @activity.trackable.involved
      growl_users.each do |user|
        user.send_notification('info', I18n.t('new_register_user_membership'), owner.name, 0, register_path(@activity.trackable))
      end
    when 'register_user_membership.cancel'
      email_users = (@activity.trackable.managers + [owner]).uniq
      email_users.each do |user|
        Notifier.send_email_notification_cancelled_register_user_membership(user, owner, @activity.trackable).deliver_now
      end
      badge_users = (@activity.trackable.involved + [owner]).uniq
      growl_users = badge_users
      growl_users.each do |user|
        user.send_notification('info', I18n.t('cancelled_register_user_membership'), owner.name, 0, register_path(@activity.trackable))
      end




    ########## register.observation ##########
    when 'register.exceeds'
      email_users = @activity.trackable.involved - User.unsubscribed_from_notification(@activity.key, @activity.trackable)
      email_users.each do |user|
        Notifier.send_email_register_exceeds_or_undershoots(user, @activity.trackable, 'exceeds').deliver_now
      end
      badge_users = @activity.trackable.involved
      growl_users = @activity.trackable.involved
      growl_users.each do |user|
        user.send_notification('info', I18n.t('register_exceeded_max_watt', register_name: @activity.trackable.name, max_watt: @activity.trackable.max_watt), @activity.trackable.name, 0, register_path(@activity.trackable))
      end
    when 'register.undershoots'
      email_users = @activity.trackable.involved - User.unsubscribed_from_notification(@activity.key, @activity.trackable)
      email_users.each do |user|
        Notifier.send_email_register_exceeds_or_undershoots(user, @activity.trackable, 'undershoots').deliver_now
      end
      badge_users = @activity.trackable.involved
      growl_users = @activity.trackable.involved
      growl_users.each do |user|
        user.send_notification('info', I18n.t('register_undershot_min_watt', register_name: @activity.trackable.name, min_watt: @activity.trackable.min_watt), @activity.trackable.name, 0, register_path(@activity.trackable))
      end
    when 'register.offline'
      email_users = @activity.trackable.involved - User.unsubscribed_from_notification(@activity.key, @activity.trackable)
      email_users.each do |user|
        Notifier.send_email_notification_meter_offline(user, @activity.trackable).deliver_now
      end
      badge_users = @activity.trackable.involved
      growl_users = @activity.trackable.involved
      growl_users.each do |user|
        user.send_notification('info', I18n.t('register_offline'), @activity.trackable.name, 0, register_path(@activity.trackable))
      end



    # when 'group.create'
    #   users = owner.friends if owner
    # when 'group.update'
    #   users = @activity.trackable.involved
    # when 'group.destroy'
    #   users = @activity.trackable.involved

    ########## user.platform_invitation ##########
    when 'user.create_platform_invitation'
      #don't send another email to the invitee! It was already sent when calling 'User.invite!'
      #no badge_users
      #no growl_users
    when 'user.accept_platform_invitation'
      Notifier.send_email_accepted_platform_invitation(@activity.recipient, owner).deliver_now
      Notifier.send_email_completed_registration(owner).deliver_now
      badge_users = [@activity.recipient]
      @activity.recipient.send_notification('info', I18n.t('accepted_platform_invitation'), I18n.t('user_has_accepted_the_invitation_to_join_the_buzzn_community_and_is_your_friend_now', user: owner.name + ' (' + owner.email + ')'), 0, profile_path(owner))


    ########## group.membership ###########
    when 'group_register_request.create'
      email_users = @activity.trackable.managers
      email_users.each do |user|
        Notifier.send_email_new_group_register_request(user, owner, @activity.recipient, @activity.trackable, 'request').deliver_now
      end
      badge_users = (email_users + @activity.recipient.managers).uniq
      growl_users = email_users
      growl_users.each do |user|
        user.send_notification('info', I18n.t('new_group_register_request'), I18n.t('user_wants_to_join_your_group_with_the_register', username: owner.name, register_name: @activity.recipient.name, group_name: @activity.trackable.name), 0, group_path(@activity.trackable))
      end
    when 'group_register_request.reject'
      email_users = (@activity.recipient.managers + @activity.trackable.managers - [owner]).uniq
      email_users.each do |user|
        Notifier.send_email_rejected_group_register_request(user, owner, @activity.recipient, @activity.trackable, 'request').deliver_now
      end
      badge_users = email_users
      growl_users = email_users
      growl_users.each do |user|
        user.send_notification('info', I18n.t('rejected_group_register_request'), I18n.t('user_rejected_the_request_with_your_register_to_join_the_group', user: owner.name, register: @activity.recipient.name, group: @activity.trackable.name), 0, group_path(@activity.trackable))
      end
    when 'group_register_invitation.create'
      email_users = @activity.recipient.managers - [owner]
      email_users.each do |user|
        Notifier.send_email_new_group_register_request(user, owner, @activity.recipient, @activity.trackable, 'invitation').deliver_now
      end
      badge_users = (email_users + @activity.trackable.managers - [owner]).uniq
      growl_users = email_users
      growl_users.each do |user|
        user.send_notification('info', I18n.t('new_group_register_invitation'), I18n.t('user_invited_you_to_join_the_group_with_your_register', username: owner.name, register_name: @activity.recipient.name, group_name: @activity.trackable.name), 0, group_path(@activity.trackable))
      end
    when 'group_register_invitation.reject'
      email_users = (@activity.trackable.managers + @activity.recipient.managers - [owner]).uniq
      email_users.each do |user|
        Notifier.send_email_rejected_group_register_request(user, owner, @activity.recipient, @activity.trackable, 'invitation').deliver_now
      end
      badge_users = email_users
      growl_users = email_users
      growl_users.each do |user|
        user.send_notification('info', I18n.t('rejected_group_register_invitation'), I18n.t('user_rejected_the_invitation_to_group_with_register', user: owner.name, register: @activity.recipient.name, group: @activity.trackable.name), 0, group_path(@activity.trackable))
      end
    when 'group_register_membership.create'
      email_users = (@activity.trackable.managers + @activity.recipient.managers).uniq
      email_users.each do |user|
        Notifier.send_email_new_group_register_membership(user, owner, @activity.recipient, @activity.trackable).deliver_now
      end
      badge_users = @activity.trackable.involved
      growl_users = badge_users
      growl_users.each do |user|
        user.send_notification('info', I18n.t('new_group_register_membership'), I18n.t('register_is_now_a_part_of_the_group', register_name: @activity.recipient.name, group_name: @activity.trackable.name), 0, group_path(@activity.trackable))
      end
    when 'group_register_membership.cancel'
      email_users = (@activity.trackable.managers + @activity.recipient.involved).uniq
      email_users.each do |user|
        Notifier.send_email_cancelled_group_register_membership(user, owner, @activity.recipient, @activity.trackable).deliver_now
      end
      badge_users = (@activity.trackable.involved + @activity.recipient.involved).uniq
      growl_users = badge_users
      growl_users.each do |user|
        user.send_notification('info', I18n.t('cancelled_group_register_membership'), I18n.t('register_is_not_a_part_of_the_group_anymore', register_name: @activity.recipient.name, group_name: @activity.trackable.name), 0, group_path(@activity.trackable))
      end


    ########## comment ###########
    when 'comment.create'
      email_users = @activity.trackable.root.commentable.members - [owner] - User.unsubscribed_from_notification(@activity.key, @activity.trackable.root.commentable)
      email_users.each do |user|
        Notifier.send_email_new_comment(user, @activity.trackable.user, @activity.trackable.root.commentable, @activity.trackable.body).deliver_now
      end
      badge_users = @activity.trackable.root.commentable.members - [owner]
      growl_users = @activity.trackable.root.commentable.members - [owner]
      message = I18n.t('at') + ' ' + @activity.trackable.root.commentable.name
      growl_users.each do |user|
        user.send_notification('info', I18n.t('new_comment_from_user', username: @activity.trackable.user.name), message, 0, polymorphic_path(@activity.trackable.root.commentable))
      end
    when 'comment.liked'
      Notifier.send_email_comment_liked(@activity.trackable.user, owner, @activity.trackable.body).deliver_now if @activity.trackable.user.wants_to_get_notified_by_email?(@activity.key, @activity.trackable.root.commentable)
      badge_users = [@activity.trackable.user]
      growl_users = badge_users
      message = I18n.t('at') + ' ' + @activity.trackable.root.commentable.name
      growl_users.each do |user|
        user.send_notification('info', I18n.t('user_liked_your_comment', username: owner.name), message, 0, polymorphic_path(@activity.trackable.root.commentable))
      end


    ########### roles management ##########
    when 'user.appointed_register_manager'
      Notifier.send_email_appointed_register_manager(@activity.trackable, owner, @activity.recipient).deliver_now
      badge_users = @activity.recipient.involved - [owner]
      @activity.trackable.send_notification('info', I18n.t('appointed_register_manager'), I18n.t('user_appointed_you_register_manager_of_the_register', user: owner.name, register: @activity.recipient.name), 0, register_path(@activity.recipient))
    when 'user.appointed_group_manager'
      Notifier.send_email_appointed_group_manager(@activity.trackable, owner, @activity.recipient).deliver_now
      badge_users = @activity.recipient.involved - [owner]
      @activity.trackable.send_notification('info', I18n.t('appointed_group_manager'), I18n.t('user_appointed_you_group_manager_of_the_group', user: owner.name, group: @activity.recipient.name), 0, group_path(@activity.recipient))



    ########### conversation ##########
    when 'conversation.user_add'
      badge_users = @activity.trackable.members - [owner]
      growl_users = badge_users
      growl_users.each do |user|
        user.send_notification('info', I18n.t('new_user_in_conversation'), I18n.t('user_has_added_user_to_the_conversation', user: owner.name, user2: @activity.recipient.name), 0, conversations_path)
      end
    when 'conversation.user_leave'
      badge_users = @activity.trackable.members - [owner]
      growl_users = badge_users
      growl_users.each do |user|
        user.send_notification('info', I18n.t('user_left_conversation'), I18n.t('user_has_left_the_conversation', user: owner.name), 0, conversations_path)
      end
    when 'conversation.user_remove'
      email_users = [@activity.recipient]
      email_users.each do |user|
        Notifier.send_email_removed_user_from_conversation(user, owner).deliver_now
      end
      badge_users = @activity.trackable.members - [owner] + [@activity.recipient]
      growl_users = badge_users
      growl_users.each do |user|
        user.send_notification('info', I18n.t('user_removed_from_conversation'), I18n.t('user_has_removed_user_from_the_conversation', user: owner.name, user2: @activity.recipient.name), 0, conversations_path)
      end
    end


    #Since there is a link from BadgeNotification(BN) to the originial Activity the BN
    #can be created independently of the Activity.key
    badge_users.uniq.each do |user|
      BadgeNotification.create(user: user, activity: @activity)
    end
  end
end
