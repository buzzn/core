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
  end


  def create
    @metering_point = MeteringPoint.new(metering_point_params)
    authorize_action_for @metering_point
    if @metering_point.save
      current_user.add_role :manager, @metering_point
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
    @metering_point.registers.each do |register|
      @chart_data << {name: register.mode, data: register.send(params[:resolution])}
    end
    render json: @chart_data.to_json
  end


  def latest_slp
    render json: Reading.latest_slp.to_json
  end


  def update_parent
    @metering_point = MeteringPoint.find(params[:id])
    @parent = MeteringPoint.find(params[:parent_id])
    @metering_point.parent = @parent
    authorize_action_for(@metering_point)
    @metering_point.save!
  end
  authority_actions :update_parent => 'update'





private
  def metering_point_params
    params.require(:metering_point).permit(
      :uid,
      :name,
      :image,
      :parent_id,
      :user_ids => [],
      :device_ids => []
    )
  end




end
