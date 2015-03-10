class AddressesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js, :json


  def show
    @address = Address.find(params[:id]).decorate
    gon.push({ markers: [
      {
        "lat": @address.latitude,
        "lng": @address.longitude
      }
    ]})
    authorize_action_for(@address)
  end



  def new
    @address = Address.new
    authorize_action_for(@address)
  end

  def create
    @address = Address.new(address_params)
    authorize_action_for @address
    if @address.save!
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