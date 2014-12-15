class ProfilesController < InheritedResources::Base
  before_filter :authenticate_user!


  def show
    @profile              = Profile.find(params[:id]).decorate
    @friends              = @profile.user.friends
    @metering_points      = @profile.user.metering_points

    @locations            = @profile.user.editable_locations
    @metering_points.collect(&:location).compact.each do |location|
      if !@locations.include?(location)
        @locations << location
      end
    end
    @friendship_requests  = @profile.user.received_friendship_requests

    @groups               = @metering_points.collect(&:group).compact.uniq{|group| group.id} # TODO also include group interested

    @activities           = PublicActivity::Activity
                              .order("created_at desc")
                              .where(owner_id: @profile.user.id, owner_type: "User")
                              .limit(10)
    if @metering_points
      gon.push({  register_ids: @metering_points.collect(&:registers).flatten.collect(&:id),
                  pusher_key: Rails.application.secrets.pusher_key,
                  pusher_host: Rails.application.secrets.pusher_host })
    else
      gon.push({  register_ids: [],
                  pusher_key: Rails.application.secrets.pusher_key,
                  pusher_host: Rails.application.secrets.pusher_host })
    end
    show!
  end

  def redirect_to_current_user
    @profile = current_user.profile
    redirect_to @profile
  end

  def edit
    edit! do |format|
      @profile = ProfileDecorator.new(@profile)
    end
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
      :username,
      :image,
      :first_name,
      :last_name,
      :gender,
      :phone,
      :newsletter_notifications,
      :location_notifications,
      :group_notifications,
      :description
    ]
  end
end