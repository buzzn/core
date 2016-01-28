class NotificationCreationWorker
  include Sidekiq::Worker

  def perform(activity_id)
    @activity = PublicActivity::Activity.find(activity_id)
    owner = @activity.owner
    users = []
    case @activity.key
    when 'friendship.create'
      users = owner.friends + @activity.recipient.friends
    when 'friendship_request.create' #TODO: create this
      users = @activity.recipient
    when 'metering_point.create'
      users = owner.friends
    when 'metering_point.update'
      users = @activity.trackable.members
    when 'metering_point.destroy'
      users = @activity.trackable.members
    when 'metering_point_user_request.create' #TODO: create this
      users = @activity.trackable.managers
    when 'metering_point_user_invitation.create' #TODO: create this
      users = @activity.trackable.managers
    when 'metering_point_user_membership.create'
      users = @activity.trackable.members
    when 'group.create'
      users = owner.friends
    when 'group.update'
      users = @activity.trackable.members
    when 'group.destroy'
      users = @activity.trackable.members
    when 'group.joined'
      users = @activity.trackable.members
    when 'group_metering_point_request.create' #TODO: create this
      users = @activity.trackable.managers
    when 'group_metering_point_invitation.create' #TODO: create this
      users = @activity.trackable.managers
    when 'group_metering_point_membership.create'
      users = @activity.trackable.members
    when 'comment.create'
      users = @activity.trackable.commentable.members
    when 'comment.liked'
      users = @activity.trackable.commentable.members
    when 'device.create'
      users = owner.friends
    when 'device.destroy'
      users = owner.friends
    end
    users << owner
    users << @activity.recipient if @activity.recipient != nil && @activity.recipient_type == 'User'
    users.uniq.each do |user|
      BadgeNotification.create(user: user, activity: @activity)
    end
  end
end