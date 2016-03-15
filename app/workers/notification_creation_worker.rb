class NotificationCreationWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers

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
      badge_users = [@activity.recipient, @activity.owner]
      @activity.recipient.send_notification('info', I18n.t('new_friendship_request'), owner.name, 0, profile_path(owner.profile)) if owner.profile
    when 'friendship.create'
      Notifier.send_email_notification_accepted_friendship_request(@activity.recipient, @activity.owner).deliver_now
      badge_users = @activity.owner.friends + @activity.recipient.friends + [@activity.recipient, @activity.owner]
      @activity.recipient.send_notification('info', I18n.t('accepted_friendship_request'), I18n.t('user_is_your_friend_now', user_name: owner.name), 0, profile_path(owner.profile)) if owner.profile
    when 'friendship_request.reject'
      Notifier.send_email_notification_rejected_friendship_request(@activity.recipient, @activity.owner).deliver_now
      badge_users = [@activity.recipient, @activity.owner]
      @activity.recipient.send_notification('info', I18n.t('rejected_friendship_request'), I18n.t('user_rejected_your_friendship_request', user: owner.name), 0, profile_path(owner.profile)) if owner.profile
    when 'friendship.cancel'
      Notifier.send_email_notification_cancelled_friendship(@activity.recipient, @activity.owner).deliver_now
      badge_users = [@activity.recipient, @activity.owner]
      @activity.recipient.send_notification('info', I18n.t('cancelled_friendship'), I18n.t('user_cancelled_the_friendship_with_you', user: owner.name), 0, profile_path(owner.profile)) if owner.profile

    # when 'metering_point.create'
    #   users = owner.friends if owner
    # when 'metering_point.update'
    #   users = @activity.trackable.involved
    # when 'metering_point.destroy'
    #   users = @activity.trackable.involved

    ########## metering_point.membership ###########
    when 'metering_point_user_request.create'
      email_users = @activity.trackable.managers
      email_users.each do |user|
        Notifier.send_email_notification_new_metering_point_user_request(user, owner, @activity.trackable, 'request').deliver_now
      end
      badge_users = email_users
      growl_users = email_users
      growl_users.each do |user|
        user.send_notification('info', I18n.t('new_metering_point_user_request'), I18n.t('user_wants_to_join_your_metering_point', user: owner.name, metering_point: @activity.trackable.name), 0, metering_point_path(@activity.trackable))
      end
    when 'metering_point_user_request.reject'
      Notifier.send_email_notification_rejected_metering_point_user_request(@activity.recipient, owner, @activity.trackable, 'request').deliver_now
      badge_users = @activity.trackable.managers + [@activity.recipient]
      @activity.recipient.send_notification('info', I18n.t('rejected_metering_point_user_request'), @activity.trackable.name, 0, metering_point_path(@activity.trackable))
    when 'metering_point_user_invitation.create'
      Notifier.send_email_notification_new_metering_point_user_request(@activity.recipient, owner, @activity.trackable, 'invitation').deliver_now
      badge_users = @activity.trackable.managers + [@activity.recipient]
      @activity.recipient.send_notification('info', I18n.t('new_metering_point_user_invitation'), I18n.t('user_invited_you_to_join_the_metering_point', user: owner.name, metering_point: @activity.trackable.name), 0, metering_point_path(@activity.trackable))
    when 'metering_point_user_invitation.reject'
      email_users = @activity.trackable.managers
      email_users.each do |user|
        Notifier.send_email_notification_rejected_metering_point_user_request(user, owner, @activity.trackable, 'invitation').deliver_now
      end
      badge_users = email_users + [owner]
      growl_users = @activity.trackable.managers
      growl_users.each do |user|
        user.send_notification('info', I18n.t('rejected_metering_point_user_invitation'), owner.name, 0, profile_path(owner))
      end
    when 'metering_point_user_membership.create'
      email_users = @activity.trackable.involved
      email_users.each do |user|
        Notifier.send_email_notification_new_metering_point_user_membership(user, owner, @activity.trackable).deliver_now
      end
      badge_users = (email_users + owner.friends).uniq
      growl_users = email_users
      growl_users.each do |user|
        user.send_notification('info', I18n.t('new_metering_point_user_membership'), owner.name, 0, metering_point_path(@activity.trackable))
      end
    when 'metering_point_user_membership.cancel'
      email_users = @activity.trackable.involved + [owner]
      email_users.each do |user|
        Notifier.send_email_notification_cancelled_metering_point_user_membership(user, owner, @activity.trackable).deliver_now
      end
      badge_users = email_users
      growl_users = email_users
      growl_users.each do |user|
        user.send_notification('info', I18n.t('cancelled_metering_point_user_membership'), owner.name, 0, metering_point_path(@activity.trackable))
      end


    # when 'group.create'
    #   users = owner.friends if owner
    # when 'group.update'
    #   users = @activity.trackable.involved
    # when 'group.destroy'
    #   users = @activity.trackable.involved


    # when 'platform_user_invitation.create'
    # when 'platform_user_invitation.accepted'

    ########## group.membership ###########
    when 'group_metering_point_request.create'
      email_users = @activity.trackable.managers
      email_users.each do |user|
        Notifier.send_email_new_group_metering_point_request(user, owner, @activity.recipient, @activity.trackable, 'request').deliver_now
      end
      badge_users = (email_users + @activity.recipient.managers).uniq
      growl_users = email_users
      growl_users.each do |user|
        user.send_notification('info', I18n.t('new_group_metering_point_request'), I18n.t('user_wants_to_join_your_group_with_the_metering_point', username: owner, metering_point_name: @activity.recipient.name, group_name: @activity.trackable.name), 0, group_path(@activity.trackable))
      end
    when 'group_metering_point_request.reject'
      email_users = @activity.recipient.managers
      email_users.each do |user|
        Notifier.send_email_rejected_group_metering_point_request(user, owner, @activity.recipient, @activity.trackable, 'request').deliver_now
      end
      badge_users = (email_users + @activity.trackable.managers).uniq
      growl_users = email_users
      growl_users.each do |user|
        user.send_notification('info', I18n.t('rejected_group_metering_point_request'), I18n.t('user_rejected_the_request_with_your_metering_point_to_join_the_group', user: owner, metering_point: @activity.recipient.name, group: @activity.trackable.name), 0, group_path(@activity.trackable))
      end
    when 'group_metering_point_invitation.create'
      email_users = @activity.recipient.managers
      email_users.each do |user|
        Notifier.send_email_new_group_metering_point_request(user, owner, @activity.recipient, @activity.trackable, 'invitation').deliver_now
      end
      badge_users = (email_users + @activity.trackable.managers).uniq
      growl_users = email_users
      growl_users.each do |user|
        user.send_notification('info', I18n.t('new_group_metering_point_invitation'), I18n.t('user_invited_you_to_join_the_group_with_your_metering_point', user: owner, metering_point: @activity.recipient.name, group: @activity.trackable.name), 0, group_path(@activity.trackable))
      end
    when 'group_metering_point_invitation.reject'
      email_users = @activity.trackable.managers
      email_users.each do |user|
        Notifier.send_email_rejected_group_metering_point_request(user, owner, @activity.recipient, @activity.trackable, 'invitation').deliver_now
      end
      badge_users = (email_users + @activity.recipient.managers).uniq
      growl_users = email_users
      growl_users.each do |user|
        user.send_notification('info', I18n.t('rejected_group_metering_point_invitation'), I18n.t('user_rejected_the_invitation_to_group_with_metering_point', user: owner, metering_point: @activity.recipient.name, group: @activity.trackable.name), 0, group_path(@activity.trackable))
      end
    when 'group_metering_point_membership.create'
      email_users = @activity.trackable.involved
      email_users.each do |user|
        Notifier.send_email_new_group_metering_point_membership(user, owner, @activity.recipient, @activity.trackable).deliver_now
      end
      badge_users = email_users
      growl_users = email_users
      growl_users.each do |user|
        user.send_notification('info', I18n.t('new_group_metering_point_membership'), I18n.t('metering_point_is_now_a_part_of_the_group', metering_point: @activity.recipient.name, group: @activity.trackable.name), 0, group_path(@activity.trackable))
      end
    when 'group_metering_point_membership.cancel'
      email_users = (@activity.trackable.managers + @activity.recipient.involved).uniq
      email_users.each do |user|
        Notifier.send_email_cancelled_group_metering_point_membership(user, owner, @activity.recipient, @activity.trackable).deliver_now
      end
      badge_users = @activity.trackable.involved
      growl_users = email_users
      growl_users.each do |user|
        user.send_notification('info', I18n.t('cancelled_group_metering_point_membership'), I18n.t('metering_point_is_not_a_part_of_the_group_anymore', metering_point: @activity.recipient.name, group: @activity.trackable.name), 0, group_path(@activity.trackable))
      end


    ########## comment ###########
    when 'comment.create'
      email_users = @activity.trackable.root.commentable.involved - [owner]
      email_users.each do |user|
        Notifier.send_email_new_comment(user, @activity.trackable.user, @activity.trackable.root.commentable, @activity.trackable.body).deliver_now
      end
      badge_users = email_users
      growl_users = email_users
      message = I18n.t('at') + ' ' + @activity.trackable.root.commentable.name
      growl_users.each do |user|
        user.send_notification('info', I18n.t('new_comment_from_user', username: @activity.trackable.user.name), message, 0, polymorphic_path(@activity.trackable.root.commentable))
      end
    when 'comment.liked'
      Notifier.send_email_comment_liked(@activity.trackable.user, owner, @activity.trackable.body).deliver_now
      badge_users = @activity.trackable.root.commentable.involved - [owner]
      if !@activity.trackable.root.commentable.readable_by_members?
        badge_users = (badge_users + owner.friends).uniq
      end
      growl_users = badge_users
      message = I18n.t('at') + ' ' + @activity.trackable.root.commentable.name
      growl_users.each do |user|
        user.send_notification('info', I18n.t('user_liked_your_comment', username: owner.name), message, 0, polymorphic_path(@activity.trackable.root.commentable))
      end
    end
    badge_users.uniq.each do |user|
      BadgeNotification.create(user: user, activity: @activity)
    end

  end
end
