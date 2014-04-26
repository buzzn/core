class MeteringPointsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js


  def new
    @metering_point         = MeteringPoint.new
    @metering_point.meter   = Meter.new
    new!
  end


  def update
    update! do |format|
      @metering_point = MeteringPointDecorator.new(@metering_point)
    end
  end

  def create
    create! do |format|
      @metering_point = MeteringPointDecorator.new(@metering_point)
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
      :location_id,
      :uid,
      :mode,
      :address_addition,
      meter_attributes: [:id, :manufacturer_name, :manufacturer_product_number, :manufacturer_meter_number, :virtual, :_destroy]
    ]
  end



end
