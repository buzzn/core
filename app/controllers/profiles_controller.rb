class ProfilesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js, :json


  def index
    @profiles = Profile.search(params[:search]).decorate
  end


  def show
    @profile              = Profile.find(params[:id]).decorate
    @friends              = @profile.user.friends.decorate
    @metering_points      = MeteringPoint.where(id: @profile.user.accessible_metering_points.map(&:id)).paginate(:page => params[:metering_point_page], :per_page => 10)
    @friendship_requests  = @profile.user.received_friendship_requests
    @metering_point_invitations = @profile.user.received_metering_point_user_requests
    @group_invitations    = @profile.user.received_group_metering_point_requests
    @groups               = Group.where(id: @profile.user.accessible_groups.map(&:id)).paginate(:page => params[:group_page], :per_page => 3) # TODO also include group interested
    @devices              = Device.with_role(:manager, @profile.user).decorate
    @activities           = PublicActivity::Activity
                              .order("created_at desc")
                              .where("owner_id = (?) OR recipient_id = (?)", @profile.user.id, @profile.user.id)
                              .where("owner_type = (?) OR recipient_type = (?)", "User", "User")
                              .limit(10)
    if request.path != profile_path(@profile)
      redirect_to profile_path(@profile), status: :moved_permanently
    end
  end


  def edit
    @profile = Profile.find(params[:id]).decorate
    authorize_action_for @profile
  end


  def update
    @profile = Profile.find(params[:id])
    authorize_action_for @profile
    if @profile.update_attributes(profile_params)
      respond_with @profile
    else
      render :edit
    end
  end


  def redirect_to_current_user
    redirect_to current_user.profile
  end


  def check_destroyable
    #byebug
    @profile = Profile.find(params[:id])
    @user = @profile.user
  end


  def read_new_badge_notifications
    @profile = Profile.find_by_slug(params[:id].parameterize)
    @user = @profile.user
    @user.new_badge_notifications.update_all(read_by_user: true)
  end

  def edit_notifications
    @profile = Profile.find(params[:id])
  end
  #TODO: add authority_actions

  def edit_notifications_update
    @profile = Profile.find(params[:id])
    notify_when_comment_create = params[:profile][:notify_me_when_comment_create]
    notify_when_comment_liked = params[:profile][:notify_me_when_comment_liked]
    notify_when_metering_point_exceeds = params[:profile][:notify_me_when_metering_point_exceeds]
    notify_when_metering_point_undershoots = params[:profile][:notify_me_when_metering_point_undershoots]
    notify_when_metering_point_offline = params[:profile][:notify_me_when_metering_point_offline]

    notification_unsubscriber_comment_create = NotificationUnsubscriber.by_user(current_user).by_resource(nil).by_key('comment.create').first
    notification_unsubscriber_comment_liked = NotificationUnsubscriber.by_user(current_user).by_resource(nil).by_key('comment.liked').first
    notification_unsubscriber_metering_point_exceeds = NotificationUnsubscriber.by_user(current_user).by_resource(nil).by_key('metering_point.exceeds').first
    notification_unsubscriber_metering_point_undershoots = NotificationUnsubscriber.by_user(current_user).by_resource(nil).by_key('metering_point.undershoots').first
    notification_unsubscriber_metering_point_offline = NotificationUnsubscriber.by_user(current_user).by_resource(nil).by_key('metering_point.offline').first

    if notify_when_comment_create == "0"
      if !notification_unsubscriber_comment_create
        NotificationUnsubscriber.create(trackable: nil, user: current_user, notification_key: 'comment.create', channel: 'email')
      end
    else
      notification_unsubscriber_comment_create.destroy if notification_unsubscriber_comment_create
    end
    if notify_when_comment_liked == "0"
      if !notification_unsubscriber_comment_liked
        NotificationUnsubscriber.create(trackable: nil, user: current_user, notification_key: 'comment.liked', channel: 'email')
      end
    else
      notification_unsubscriber_comment_liked.destroy if notification_unsubscriber_comment_liked
    end
    if notify_when_metering_point_exceeds == "0"
      if !notification_unsubscriber_metering_point_exceeds
        NotificationUnsubscriber.create(trackable: nil, user: current_user, notification_key: 'metering_point.exceeds', channel: 'email')
      end
    else
      notification_unsubscriber_metering_point_exceeds.destroy if notification_unsubscriber_metering_point_exceeds
    end
    if notify_when_metering_point_undershoots == "0"
      if !notification_unsubscriber_metering_point_undershoots
        NotificationUnsubscriber.create(trackable: nil, user: current_user, notification_key: 'metering_point.undershoots', channel: 'email')
      end
    else
     notification_unsubscriber_metering_point_undershoots .destroy if notification_unsubscriber_metering_point_undershoots
    end
    if notify_when_metering_point_offline == "0"
      if !notification_unsubscriber_metering_point_offline
        NotificationUnsubscriber.create(trackable: nil, user: current_user, notification_key: 'metering_point.offline', channel: 'email')
      end
    else
      notification_unsubscriber_metering_point_offline.destroy if notification_unsubscriber_metering_point_offline
    end
    flash[:notice] = t('settings_saved')
  end
  #TODO: add authority_actions

  def access_tokens
    @profile = Profile.find(params[:id])
    authorize_action_for @profile
    @access_tokens = Doorkeeper::AccessToken.where(
                          expires_in: nil,
                          resource_owner_id: @profile.user.id
                          )
  end
  authority_actions :access_tokens => 'update'


private
  def profile_params
    params.require(:profile).permit(
      :user_name,
      :first_name,
      :last_name,
      :image,
      :gender,
      :phone,
      :about_me,
      :newsletter_notifications,
      :location_notifications,
      :group_notifications,
      :email_notification_meter_offline
    )
  end

end
