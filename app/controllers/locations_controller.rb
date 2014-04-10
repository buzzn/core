class LocationsController < InheritedResources::Base
  before_filter :authenticate_user!

  def new
    @location                 = Location.new
    @location.address         = Address.new
    @location.metering_points << MeteringPoint.new(meter: Meter.new)
  end


  def create
    @location = Location.new(location_params)
    if @location.save
      current_user.add_role :manager, @location
      redirect_to current_user
    else
      render 'new'
    end
  end


protected
  def permitted_params
    params.permit(:location => init_permitted_params)
  end

private
  def location_params
    params.require(:location).permit(init_permitted_params)
  end

  def init_permitted_params
    [
      address_attributes: [:id, :street, :city, :state, :zip, :country, :_destroy],
      metering_points_attributes: [
        :id,
        :uid,
        :address_addition,
        :_destroy,
        meter_attributes: [:id, :manufacturer, :uid, :_destroy]
      ]
    ]
  end





end

