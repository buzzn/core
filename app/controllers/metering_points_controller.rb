class MeteringPointsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js

  def show
    @metering_point = MeteringPoint.find(params[:id]).decorate
    @users          = @metering_point.users
    @devices        = @metering_point.devices
    gon.push({
                day_to_hours:       @metering_point.register.day_to_hours,
                fake_day_to_hours:  Register.standart_profile_day_to_hours,
                fake_day_to_hours2: [[0, 1], [1, 5], [2, 3], [3, 4], [4, 10], [5, 12], [6, 9], [7, 8], [8, 5], [9, 10]],
                fake_week_to_days:  [[1, 12], [2, 10], [3, 13], [4, 9], [5, 11], [6, 14], [7, 15]],
                fake_month_to_days:  [[1, 12], [2, 10], [3, 13], [4, 9], [5, 11], [6, 14], [7, 15], [8, 12], [9, 10], [10, 13], [11, 9], [12, 11], [13, 14], [14, 15], [15, 12], [16, 10], [17, 13], [18, 9], [19, 11], [20, 14], [21, 15]]
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
