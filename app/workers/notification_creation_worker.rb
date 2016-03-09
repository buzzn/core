class NotificationCreationWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers

  def perform(activity_id)
    @activity = PublicActivity::Activity.find(activity_id)
    owner = @activity.owner
    email_users = []
    growl_users = []
    badge_users = []
    case @activity.key
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
    #   users = @activity.trackable.members
    # when 'metering_point.destroy'
    #   users = @activity.trackable.members
    when 'metering_point_user_request.create'
      email_users = @activity.trackable.managers
      email_users.each do |user|
        Notifier.send_email_notification_new_metering_point_user_request(user, owner, @activity.trackable, 'request')
      end
      badge_users = email_users
      growl_users = email_users
      growl_users.each do |user|
        user.send_notification('info', t('new_metering_point_user_request'), owner.name, 0, metering_point_path(@activity.trackable))
      end
    when 'metering_point_user_request.reject'
      Notifier.send_email_notification_rejected_metering_point_user_request(@activity.recipient, owner, @activity.trackable, 'request')
      badge_users = @activity.trackable.managers + [@activity.recipient]
      @activity.recipient.send_notification('info', t('rejected_metering_point_user_request'), @activity.trackable.name, 0, metering_point_path(@activity.trackable))
    when 'metering_point_user_invitation.create'
      users = @activity.trackable.managers
    when 'metering_point_user_invitation.reject'
      email_users = @activity.trackable.managers
      email_users.each do |user|
        Notifier.send_email_notification_rejected_metering_point_user_request(user, owner, @activity.trackable, 'invitation')
      end
      badge_users = email_users + [owner]
      growl_users = email_users
      growl_users.each do |user|
        user.send_notification('info', t('rejected_metering_point_user_invitation'), owner.name, 0, profile_path(owner))
      end
    when 'metering_point_user_membership.create'
      users = @activity.trackable.members
    when 'metering_point_user_membership.cancel'
      users = @activity.trackable.members
    # when 'group.create'
    #   users = owner.friends if owner
    # when 'group.update'
    #   users = @activity.trackable.members
    # when 'group.destroy'
    #   users = @activity.trackable.members
    # when 'group.joined'
    #   users = @activity.trackable.members
    # when 'group_metering_point_request.create' #TODO: create this
    #   users = @activity.trackable.managers
    # when 'group_metering_point_invitation.create' #TODO: create this
    #   users = @activity.trackable.managers
    # when 'group_metering_point_membership.create'
    #   users = @activity.trackable.members

    when 'comment.create'
      email_users = @activity.trackable.root.commentable.members - [owner]
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
      badge_users = @activity.trackable.root.commentable.members - [owner]
      if !@activity.trackable.root.commentable.readable_by_members?
        badge_users = (badge_users + owner.friends).uniq
      end
      growl_users = badge_users
      message = I18n.t('at') + ' ' + @activity.trackable.root.commentable.name
      growl_users.each do |user|
        user.send_notification('info', I18n.t('user_liked_your_comment', username: owner.name), message, 0, polymorphic_path(@activity.trackable.root.commentable))
      end

    # when 'device.create'
    #   users = owner.friends
    # when 'device.destroy'
    #   users = owner.friends
    end
    badge_users.uniq.each do |user|
      BadgeNotification.create(user: user, activity: @activity)
    end

  end
end
