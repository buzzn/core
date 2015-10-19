class ActivitiesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js, :json


  def voted
    @activity = PublicActivity::Activity.find(params[:id])
    if current_user.liked?(@activity)
      @activity.unliked_by current_user
    else
      @activity.liked_by current_user
    end
    @channel_name = @activity.trackable_type + '_' + @activity.trackable_id
    @div = 'activity_' + @activity.id
    Pusher.trigger(@channel_name, 'likes_changed', :div => @div, :likes => @activity.get_likes.size, :socket_id => @socket_id)
    render :json => { :likes => @activity.get_likes.size, :liked_by_current_user => current_user.liked?(@activity) }
  end


end