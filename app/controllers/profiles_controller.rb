class ProfilesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js, :json


  def index
    @profiles = Profile.search(params[:search]).decorate
  end


  def show
    @profile              = Profile.find(params[:id]).decorate
    @friends              = @profile.user.friends.decorate
    @metering_points      = @profile.metering_points
    @friendship_requests  = @profile.user.received_friendship_requests
    @metering_point_invitations = @profile.user.received_metering_point_user_requests
    @group_invitations    = @profile.user.received_group_metering_point_requests
    @groups               = @metering_points.collect(&:group).compact.uniq{|group| group.id} # TODO also include group interested
    @devices              = Device.with_role(:manager, @profile.user).decorate
    @activities           = PublicActivity::Activity
                              .order("created_at desc")
                              .where("owner_id = (?) OR recipient_id = (?)", @profile.user.id, @profile.user.id)
                              .where("owner_type = (?) OR recipient_type = (?)", "User", "User")
                              .limit(10)
    if request.path != profile_path(@profile)
      redirect_to @profile, status: :moved_permanently
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