class MeteringPointsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js

  def show
    @metering_point = MeteringPoint.find(params[:id]).decorate
    @users          = @metering_point.users
    @devices        = @metering_point.devices
    gon.push({
                day_to_hours:       @metering_point.register.day_to_hours,
                fake_day_to_hours:  [[Time.now.to_i * 1000 - 9*3600 * 1000, 3], [Time.now.to_i * 1000 - 8*3600 * 1000, 3], [Time.now.to_i * 1000 - 7*3600 * 1000, 5], [Time.now.to_i * 1000 - 6*3600 * 1000, 7], [Time.now.to_i * 1000 - 5*3600 * 1000, 8], [Time.now.to_i * 1000 - 4*3600 * 1000, 10], [Time.now.to_i * 1000 - 3*3600 * 1000, 11], [Time.now.to_i * 1000 - 2*3600 * 1000, 9], [Time.now.to_i * 1000 - 3600 * 1000, 5], [Time.now.to_i * 1000, 13]],
                fake_day_to_hours2: [[Time.now.to_i * 1000 - 9*3600 * 1000, 1], [Time.now.to_i * 1000 - 8*3600 * 1000, 5], [Time.now.to_i * 1000 - 7*3600 * 1000, 3], [Time.now.to_i * 1000 - 6*3600 * 1000, 4], [Time.now.to_i * 1000 - 5*3600 * 1000, 10], [Time.now.to_i * 1000 - 4*3600 * 1000, 12], [Time.now.to_i * 1000 - 3*3600 * 1000, 9], [Time.now.to_i * 1000 - 2*3600 * 1000, 8], [Time.now.to_i * 1000 - 3600 * 1000, 5], [Time.now.to_i * 1000, 10]],
                fake_day_to_hours3:  Register.standart_profile_day_to_hours,
                fake_week_to_days:  [[1, 12], [2, 10], [3, 13], [4, 9], [5, 11], [6, 14], [7, 15]],
                fake_month_to_days:  [[1, 12], [2, 10], [3, 13], [4, 9], [5, 11], [6, 14], [7, 15], [8, 12], [9, 10], [10, 13], [11, 9], [12, 11], [13, 14], [14, 15], [15, 12], [16, 10], [17, 13], [18, 9], [19, 11], [20, 14], [21, 15]],
                fake_month_to_days2: [[Time.now.to_i * 1000, 12], [Time.now.to_i * 1000 + 86400*1000, 10], [Time.now.to_i * 1000 + 2*86400*1000, 13], [Time.now.to_i * 1000 + 3*86400*1000, 9], [Time.now.to_i * 1000 + 4*86400*1000, 15], [Time.now.to_i * 1000 + 5*86400*1000, 11], [Time.now.to_i * 1000 + 6*86400*1000, 7]],
                fake_real_time_data: [[Time.now.to_i*1000-10*1000, 300], [Time.now.to_i*1000-9*1000, 350], [Time.now.to_i*1000-8*1000, 325], [Time.now.to_i*1000-7*1000, 300], [Time.now.to_i*1000-6*1000, 240], [Time.now.to_i*1000-5*1000, 250], [Time.now.to_i*1000-4*1000, 230], [Time.now.to_i*1000-3*1000, 510], [Time.now.to_i*1000-2*1000, 500], [Time.now.to_i*1000-1*1000, 490], [Time.now.to_i*1000, 470]]
              })
    show!
  end



  def edit
    @metering_point = MeteringPoint.find(params[:id]).decorate
    authorize_action_for(@metering_point)
    edit!
  end


  def edit_users
    @metering_point = MeteringPoint.find(params[:id]).decorate
    authorize_action_for(@metering_point)
    edit!
  end
  authority_actions :edit_users => 'update'


  def update
    update! do |format|
      @metering_point = MeteringPoint.new(@metering_point).decorate
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
      :address_addition,
      :user_ids => []
    ]
  end




end
