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

  def add_metering_point
    @dashboard = Dashboard.find(params[:slug])
    @metering_point = MeteringPoint.find(params[:metering_point_id])
    if !@dashboard.metering_points.include?(@metering_point)
      @dashboard.metering_points << @metering_point
      @dashboard.save
    end
  end

  def remove_metering_point
    @dashboard = Dashboard.find(params[:slug])
    @metering_point = MeteringPoint.find(params[:metering_point_id])
    if @dashboard.metering_points.include?(@metering_point)
      @dashboard.metering_points.delete(@metering_point)
      @dashboard.save
    end
  end

end