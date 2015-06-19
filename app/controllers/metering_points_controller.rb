class MeteringPointsController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :chart, :latest_slp]
  respond_to :html, :json, :js

  def show
    @metering_point = MeteringPoint.find(params[:id]).decorate
    @users          = @metering_point.users
    @devices        = @metering_point.devices
    @group          = @metering_point.group
    @meter          = @metering_point.meter
    if !@metering_point.readable_by_world?
      if user_signed_in?
        authorize_action_for(@metering_point)
      else
        redirect_to root_path
      end
    end
  end


  def new
    @metering_point = MeteringPoint.new(mode: 'in')
    authorize_action_for @metering_point
    2.times{@metering_point.formula_parts.build}
  end


  def create
    @metering_point = MeteringPoint.new(metering_point_params)
    authorize_action_for @metering_point
    if @metering_point.save
      current_user.add_role(:manager, @metering_point)
      @metering_point.create_activity key: 'metering_point.create', owner: current_user
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

    @cache_id = "/metering_points/#{params[:id]}/chart?resolution=#{params[:resolution]}&containing_timestamp=#{params[:containing_timestamp]}"

    @cache = Rails.cache.fetch(@cache_id)

    @data = @cache || @metering_point.send(params[:resolution], params[:containing_timestamp])

    @chart_data = []
    @chart_data << {
      name: @metering_point.decorate.long_name,
      data: @data
    }
    render json: @chart_data.to_json
  end





  def latest_fake_data
    @metering_point = MeteringPoint.find(params[:id])
    if @metering_point.slp?
      render json: Reading.latest_fake_data('slp', @metering_point.forecast_kwh_pa.nil? ? 1 : @metering_point.forecast_kwh_pa/1000).to_json
    elsif @metering_point.pv?
      render json: Reading.latest_fake_data('sep_pv', @metering_point.forecast_kwh_pa.nil? ? 1 : @metering_point.forecast_kwh_pa/1000).to_json
    elsif @metering_point.bhkw_or_else?
      render json: Reading.latest_fake_data('sep_bhkw', @metering_point.forecast_kwh_pa.nil? ? 1 : @metering_point.forecast_kwh_pa/1000).to_json
    end
  end


  def latest_power
    @metering_point = MeteringPoint.find(params[:id])
    last_power = @metering_point.last_power
    render json: {
      latest_power: last_power[:power],
      timestamp:    last_power[:timestamp],
      smart:        @metering_point.smart?,
      online:       @metering_point.online?,
      virtual:      @metering_point.virtual
      }.to_json
  end






private
  def metering_point_params
    params.require(:metering_point).permit(
      :uid,
      :name,
      :image,
      :mode,
      :readable,
      :virtual,
      :group_id,
      :user_ids => [],
      :device_ids => [],
      formula_parts_attributes: [:id, :operator, :metering_point_id, :operand_id, :_destroy]
    )
  end




end
