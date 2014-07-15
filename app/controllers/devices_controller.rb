class DevicesController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js

  def show
    @device         = Device.find(params[:id]).decorate
    @metering_point = @device.metering_point
    @location       = @metering_point.location
    @users          = @metering_point.users
    show!
  end


  def new_out
    @device = Device.new
    authorize_action_for(@device)
    new!
  end
  authority_actions :new_out => 'create'

  def edit_out
    @device = Device.find(params[:id]).decorate
    authorize_action_for(@device)
    edit!
  end
  authority_actions :edit_out => 'update'



  def new_in
    @device = Device.new
    authorize_action_for(@device)
    new!
  end
  authority_actions :new_in => 'create'


  def edit_in
    @device = Device.find(params[:id]).decorate
    authorize_action_for(@device)
    edit!
  end
  authority_actions :edit_in => 'update'


  def update
    update! do |format|
      @device = DeviceDecorator.new(@device)
    end
  end

  def create
    create! do |format|
      @device = DeviceDecorator.new(@device)
    end
  end




protected
  def permitted_params
    params.permit(:device => init_permitted_params)
  end

private
  def meter_params
    params.require(:device).permit(init_permitted_params)
  end

  def init_permitted_params
    [
      :image,
      :name,
      :law,
      :generator_type,
      :manufacturer,
      :manufacturer_product_number,
      :shop_link,
      :primary_energy,
      :watt_peak,
      :commissioning,
      :metering_point_id
    ]
  end
end