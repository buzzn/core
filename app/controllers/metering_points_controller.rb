class MeteringPointsController < ApplicationController
  before_filter :authenticate_user!, except: [:chart, :latest_slp]
  respond_to :html, :json, :js

  def show
    @metering_point = MeteringPoint.find(params[:id]).decorate
    @users          = @metering_point.users
    @devices        = @metering_point.devices
    @group          = @metering_point.group
    @meter          = @metering_point.meter
    authorize_action_for(@metering_point)
  end


  def new
    @metering_point = MeteringPoint.new
    authorize_action_for @metering_point
    2.times{@metering_point.formula_parts.build}
  end


  def create
    @metering_point = MeteringPoint.new(metering_point_params)
    authorize_action_for @metering_point
    if @metering_point.save
      current_user.add_role(:manager, @metering_point)
      respond_with @metering_point.decorate
    else
      render :new
    end
  end


  def edit
    @metering_point = MeteringPoint.find(params[:id])
    authorize_action_for(@metering_point)
  end


  def update
    @metering_point = MeteringPoint.find(params[:id])
    authorize_action_for @metering_point
    if @metering_point.update_attributes(metering_point_params)
      respond_with @metering_point
    else
      render :edit
    end
  end

  def destroy
    @metering_point = MeteringPoint.find(params[:id])
    authorize_action_for @metering_point
    @metering_point.destroy
    respond_with current_user.profile
  end



  def edit_users
    # TODO: insert added user directly
    @metering_point = MeteringPoint.find(params[:id]).decorate
    authorize_action_for(@metering_point, action: 'edit_users')
  end
  authority_actions :edit_users => 'update'



  def edit_devices
    # TODO: insert added device directly
    @metering_point = MeteringPoint.find(params[:id]).decorate
    authorize_action_for(@metering_point, action: 'edit_devices')
  end
  authority_actions :edit_devices => 'update'




  def chart
    @metering_point = MeteringPoint.find(params[:id])
    @chart_data = []
    if @metering_point.is_dashboard_metering_point
      i = 0
      index = 0
      @metering_point.dashboard.dashboard_metering_points.each do |dashboard_metering_point|
        if dashboard_metering_point == @metering_point
          index = i + 1
        end
        i += 1
      end
      name = t('series') + ' ' + index.to_s
    else
      name = @metering_point.name
    end
    @chart_data << {name: name, color: '#fff', data: @metering_point.send(params[:resolution], params[:containing_timestamp])}
    render json: @chart_data.to_json
  end


  def latest_slp
    render json: Reading.latest_slp.to_json
  end







private
  def metering_point_params
    params.require(:metering_point).permit(
      :uid,
      :name,
      :image,
      :mode,
      :virtual,
      :group_id,
      :user_ids => [],
      :device_ids => [],
      formula_parts_attributes: [:id, :operator, :metering_point_id, :operand_id, :_destroy]
    )
  end




end
