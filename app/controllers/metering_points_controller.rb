class MeteringPointsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html


  def index
    @metering_points = MeteringPoint.with_role(:manager, current_user)
    index!
  end

  def new
    @metering_point         = MeteringPoint.new
    @metering_point.address = Address.new
    @metering_point.meter   = Meter.new
    new!
  end

  def create
    @metering_point         = MeteringPoint.new(meter_params)
    if @metering_point.save
      current_user.add_role :manager, @metering_point
      redirect_to @metering_point
    else
      render 'new'
    end
  end


protected
  def permitted_params
    params.permit(:metering_point => init_permitted_params)
  end

private
  def meter_params
    params.require(:metering_point).permit(init_permitted_params)
  end

  def init_permitted_params
    [
      :uid,
      address_attributes: [:id, :street, :city, :state, :zip, :country, :_destroy],
      meter_attributes: [:id, :name, :uid, :_destroy]
    ]
  end



end
