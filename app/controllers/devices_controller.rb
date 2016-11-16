class DevicesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js


  def show
    @device         = Device.find(params[:id]).decorate
    if @device.register
      @register = @device.register
      @users          = @register.users
      @group          = @register.group
    end
    @manager        = @device.editable_users
    authorize_action_for(@device)
  end

  def new
    @device = Device.new
    authorize_action_for @device
  end


  def create
    @device = Device.new(device_params)
    authorize_action_for @device
    if @device.save
      current_user.add_role :manager, @device
      #@device.create_activity key: 'device.create', owner: current_user
      @device.decorate
    else
      render :new
    end
  end


  def edit
    @device = Device.find(params[:id])
    authorize_action_for @device
  end


  def update
    @device = Device.find(params[:id])
    authorize_action_for @device
    if @device.update_attributes(device_params)
      respond_with @device
    else
      render :edit
    end
  end


  def destroy
    @device = Device.find(params[:id])
    @device.destroy
    redirect_to current_user.profile
  end



private
  def device_params
    params.require(:device).permit(
      :mode,
      :image,
      :law,
      :category,
      :manufacturer_name,
      :manufacturer_product_name,
      :manufacturer_product_serialnumber,
      :image,
      :shop_link,
      :primary_energy,
      :watt_hour_pa,
      :watt_peak,
      :commissioning,
      :register_id
      )
  end




end