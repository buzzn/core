class ActivitiesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js, :json


  def voted
    @activity = PublicActivity::Activity.find(params[:id])
    if params[:mode] == 'good'
      @activity.liked_by current_user
    elsif params[:mode] == 'bad'
      @activity.disliked_by current_user
    end
    render :json => { :likes => @activity.get_likes.size, :dislikes => @activity.get_dislikes.size}
  end


end