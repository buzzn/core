class ProfilesController < InheritedResources::Base
  before_filter :authenticate_user!


  def show
    @profile    = Profile.find(params[:id]).decorate

    @friends    = @profile.user.friends.decorate

    @friendship_requests = @profile.user.received_friendship_requests.decorate

    @activities = PublicActivity::Activity.order("created_at desc").where(owner_id: @profile.user.friend_ids << @profile.user.id, owner_type: "User").limit(10)
    # @locations  = Location
    #   .with_role(:manager, @profile.user)
    #   .includes([metering_points: [:register, :devices]])
    #   .decorate

    @locations = @profile.user.metering_points.collect(&:location)

    @groups = @profile.user.groups

    show!
  end

  def redirect_to_current_user
    @profile = current_user.profile
    redirect_to @profile
  end


protected
  def permitted_params
    params.permit(:profile => init_permitted_params)
  end

private
  def profile_params
    params.require(:profile).permit(init_permitted_params)
  end

  def init_permitted_params
    [
      :image,
      :first_name,
      :last_name,
      :gender,
      :phone,
      :newsletter_notifications,
      :location_notifications,
      :group_notifications
    ]
  end
end