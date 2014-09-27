class DevicesController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js



  def show
    @device         = Device.find(params[:id]).decorate
    @metering_point = @device.metering_point if @device.metering_point
    @location       = @metering_point.location if @metering_point
    @users          = @metering_point.users if @metering_point
    @users_all      = User.all.decorate
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
    update! do |format, success, failure|
      @device = DeviceDecorator.new(@device)
      success.js { @device }
      failure.js { render :edit }
    end
  end

  def create
    create! do |format, success, failure|
      current_user.add_role :manager, @device
      @device = DeviceDecorator.new(@device)
      success.js { @device }
      failure.js { render :new }
    end
  end




protected
  def permitted_params
    params.permit(:device => init_permitted_params)
  end

private
  def device_params
    params.require(:device).permit(init_permitted_params)
  end

  def init_permitted_params
    [
      :image,
      :law,
      :generator_type,
      :manufacturer_name,
      :manufacturer_product_name,
      :manufacturer_product_serialnumber,
      :shop_link,
      :primary_energy,
      :watt_peak,
      :commissioning,
      :metering_point_id
    ]
  end
end