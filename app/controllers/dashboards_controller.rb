class DashboardsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js

  def show
    if user_signed_in?
      @dashboard = Dashboard.find(params[:id])
      @metering_points = @dashboard.metering_points
    else
      redirect_to new_user_session_path
    end
  end

end