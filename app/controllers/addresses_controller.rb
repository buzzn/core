class AddressesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :json, :js


  def new
    @address = Address.new
    authorize_action_for(@address)
  end

  def create
    @address = Address.new(address_params)
    authorize_action_for @address
    if @address.save
      current_user.add_role :manager, @address
      respond_with @address.decorate
    else
      render :new
    end
  end



  def edit
    @address = Address.find(params[:id])
    authorize_action_for(@address)
  end


  def update
    @address = Address.find(params[:id])
    authorize_action_for @address
    if @address.update_attributes(address_params)
      respond_with @address
    else
      render :edit
    end
  end


  def destroy
    @address = Address.find(params[:id])
    authorize_action_for @address
    @address.destroy
    respond_with current_user.profile
  end

  def index
    @addresses = Address.all
    respond_to do |format|
      format.json {
        @addresses = Address.all
        @addresses_in = @addresses.collect{|address| address if address.metering_point && address.metering_point.input?}.compact.uniq{|address| address.longitude && address.latitude}
        @addresses_out = @addresses.collect{|address| address if address.metering_point && address.metering_point.output?}.compact.uniq{|address| address.longitude && address.latitude}
        result = []
        @addresses_in.each do |address|
          result << { :lat => address.latitude, :lng => address.longitude, :infowindow => address.metering_point.managers.first.name} #TODO: insert custom icons
        end
        @addresses_out.each do |address|
          result << { :lat => address.latitude, :lng => address.longitude, :infowindow => address.metering_point.managers.first.name} #TODO: insert custom icons
        end
        render json: result.to_json
      }
      format.html
    end
  end




private
  def address_params
    params.require(:address).permit(
      :address,
      :street_name,
      :street_number,
      :city,
      :state,
      :zip,
      :country,
      :time_zone,
      :addressable_id,
      :addressable_type
    )
  end




end