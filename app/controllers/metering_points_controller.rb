class MeteringPointsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :json, :js

  def show
    @metering_point = MeteringPoint.find(params[:id]).decorate
    @users          = @metering_point.users
    @devices        = @metering_point.devices
    @group          = @metering_point.group
    gon.push({
                metering_point_id:      @metering_point.id,
                metering_point_mode:    @metering_point.mode,

                actual_readings_current: @metering_point.day_to_hours_sm[:current],
                actual_readings_past:    @metering_point.day_to_hours_sm[:past],

                day_to_hours_current:   @metering_point.day_to_hours[:current],
                day_to_hours_past:      @metering_point.day_to_hours[:past],

                month_to_days_current:  @metering_point.month_to_days[:current],
                month_to_days_past:     @metering_point.month_to_days[:past],

                year_to_months_current: @metering_point.year_to_months[:current],
                year_to_months_past:    @metering_point.year_to_months[:past]
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
