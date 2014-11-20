class MeteringPointsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :json, :js
  #belongs_to :group

  def show
    @metering_point                   = MeteringPoint.find(params[:id]).decorate
    @users                            = @metering_point.users
    @devices                          = @metering_point.devices
    @group                            = @metering_point.group
    @meter                            = @metering_point.meter
    authorize_action_for(@metering_point)
    show!
  end
  authority_actions :show => 'update'



  def chart
    @metering_point = MeteringPoint.find(params[:id])
    render json: @metering_point.registers.first.day_to_hours[:current].to_json
  end


  def edit
    @metering_point = MeteringPoint.find(params[:id]).decorate
    authorize_action_for(@metering_point)
    edit!
  end


  def edit_users
    # TODO: insert added user directly
    @metering_point = MeteringPoint.find(params[:id]).decorate
    authorize_action_for(@metering_point, action: 'edit_users')
    edit!
  end
  authority_actions :edit_users => 'update'

  def edit_devices
    # TODO: insert added device directly
    @metering_point = MeteringPoint.find(params[:id]).decorate
    authorize_action_for(@metering_point, action: 'edit_devices')
    edit!
  end
  authority_actions :edit_devices => 'update'


  def update
    update! do |success, failure|
      @metering_point = MeteringPointDecorator.new(@metering_point).decorate
      success.js { @metering_point }
      failure.js { render :edit }
    end
  end

  def create
    create! do |success, failure|
      success.js { location_path(@metering_point.location) }
      failure.js { render :new }
    end
  end



protected
  def permitted_params
    params.permit(:metering_point => init_permitted_params)
  end

private
  def metering_point_params
    params.require(:metering_point).permit(init_permitted_params)
  end

  def init_permitted_params
    [
      :location_id,
      :name,
      :uid,
      :mode,
      :registers,
      :address_addition,
      :user_ids => [],
      :device_ids => []
    ]
  end




end
