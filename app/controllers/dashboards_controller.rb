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
    authorize_action_for(@dashboard)
  end

  def add_metering_point
    @dashboard = Dashboard.find(params[:dashboard_id])
    @metering_point = MeteringPoint.find(params[:metering_point_id])
    if !@dashboard.metering_points.include?(@metering_point)
      @dashboard.metering_points << @metering_point
      @dashboard.save
    end
    authorize_action_for(@dashboard)
  end
  authority_actions :add_metering_point => 'update'

  def remove_metering_point
    @dashboard = Dashboard.find(params[:dashboard_id])
    @metering_point = MeteringPoint.find(params[:metering_point_id])
    if @dashboard.metering_points.include?(@metering_point)
      @dashboard.metering_points.delete(@metering_point)
      @dashboard.save
    end
    authorize_action_for(@dashboard)
  end
  authority_actions :remove_metering_point => 'update'


  def display_metering_point_in_series
    @dashboard = Dashboard.find(params[:dashboard_id])
    @metering_point = MeteringPoint.find(params[:metering_point_id])
    #@dashboard_metering_point = @dashboard.dashboard_metering_points[params[:series].to_i - 1]
    #@operator = params[:operator]
    #@dashboard_metering_point.formula_parts << FormulaPart.create(operator: @operator, metering_point_id: @dashboard_metering_point.id, operand_id: @metering_point.id)
    @dashboard_metering_point = DashboardMeteringPoint.where(dashboard_id: @dashboard.id, metering_point_id: @metering_point.id).first
    @dashboard_metering_point.displayed = true
    @dashboard_metering_point.save
    authorize_action_for(@dashboard)
  end
  authority_actions :display_metering_point_in_series => 'update'


  def remove_metering_point_from_series
    @dashboard = Dashboard.find(params[:dashboard_id])
    @metering_point = MeteringPoint.find(params[:metering_point_id])
    @dashboard_metering_point = DashboardMeteringPoint.where(dashboard_id: @dashboard.id, metering_point_id: @metering_point.id).first
    @dashboard_metering_point.displayed = false
    @dashboard_metering_point.save
    authorize_action_for(@dashboard)
  end
  authority_actions :remove_metering_point_from_series => 'update'

end