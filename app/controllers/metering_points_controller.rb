class MeteringPointsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :json, :js

  def show
    @metering_point = MeteringPoint.find(params[:id]).decorate
    @users          = @metering_point.users
    @devices        = @metering_point.devices
    @group          = @metering_point.group
    @registers      = @metering_point.registers
    @meter          = @metering_point.meter

    register_data = []
    @registers.each do |register|
      register_data << {
        id:             register.id,
        day_to_hours:   register.day_to_hours,
        month_to_days:  register.month_to_days,
        year_to_months: register.year_to_months
      }
    end


    gon.push({

                metering_point_id:    @metering_point.id,
                metering_point_mode:  @metering_point.mode,
                chart_types:          ['day_to_hours', 'month_to_days', 'year_to_months'],
                charts_data:          register_data
            })
    show!
  end



  def edit
    @metering_point = MeteringPoint.find(params[:id]).decorate
    authorize_action_for(@metering_point)
    edit!
  end


  def edit_users
    # TODO: insert added user directly
    @metering_point = MeteringPoint.find(params[:id]).decorate
    authorize_action_for(@metering_point)
    edit!
  end
  authority_actions :edit_users => 'update'

  def edit_devices
    # TODO: insert added device directly
    @metering_point = MeteringPoint.find(params[:id]).decorate
    authorize_action_for(@metering_point)
  end
  authority_actions :edit_devices => 'update'


  def update
    update! do |format|
      @metering_point = MeteringPointDecorator.new(@metering_point).decorate
    end
  end

  def create
    # TODO create.js is not working. remote:false on create
    # create! do |format|
    #   @metering_point = MeteringPointDecorator.new(@metering_point)
    # end
    create! { location_path(@metering_point.location) }
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
