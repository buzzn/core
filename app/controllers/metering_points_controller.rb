class MeteringPointsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :json, :js
  #belongs_to :group

  def show
    @metering_point                   = MeteringPoint.find(params[:id]).decorate
    @users                            = @metering_point.users
    @devices                          = @metering_point.devices
    @group                            = @metering_point.group
    @registers                        = @metering_point.registers
    @meter                            = @metering_point.meter

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
                end_of_day:           Time.now.end_of_day.to_i * 1000 - 59 * 1000 - 29 * 60 * 1000,
                beginning_of_month:   Time.now.in_time_zone.beginning_of_month.to_i * 1000 - 12 * 3600 * 1000,
                end_of_month:         Time.now.in_time_zone.end_of_month.to_i * 1000 - 59 * 1000 - 59 * 60 * 1000 - 12 * 3600 * 1000,
                beginning_of_year:    Time.now.in_time_zone.beginning_of_year.to_i * 1000 - 15 * 24 * 3600 * 1000,
                end_of_year:          Time.now.in_time_zone.end_of_year.to_i * 1000 - 59 * 1000 - 59 * 60 * 1000 - 23 * 3600 * 1000 - 15 * 24 * 3600 * 1000,
                metering_point_id:    @metering_point.id,
                metering_point_mode:  @metering_point.mode,
                chart_types:          ['day_to_hours', 'month_to_days', 'year_to_months'],
                charts_data:          register_data
            })
    authorize_action_for(@metering_point)
    show!
  end
  authority_actions :show => 'update'



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
