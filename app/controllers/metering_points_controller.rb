class MeteringPointsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js

  belongs_to :location

  def show
    @metering_point = MeteringPoint.find(params[:id]).decorate
    show!
  end


  # def new
  #   @metering_point = MeteringPoint.new
  #   @metering_point.register = Meter.new(registers:[Register.new()])
  #   new!
  # end


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
      @metering_point = MeteringPointDecorator.new(@metering_point)
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
