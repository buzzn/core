class MetersController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js

protected
  def permitted_params
    params.permit(:meter => init_permitted_params)
  end

private
  def meter_params
    params.require(:meter).permit(init_permitted_params)
  end

  def init_permitted_params
    [
      :metering_point_id,
      :manufacturer_name,
      :manufacturer_product_number,
      :manufacturer_meter_number,
      :virtual
    ]
  end
end