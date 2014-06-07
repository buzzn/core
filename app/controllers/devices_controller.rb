class DevicesController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js

  def new_up
    @device = Device.new
    authorize_action_for(@device)
    new!
  end

  def new_down
    @device = Device.new
    authorize_action_for(@device)
    new!
  end



  def edit_up
    @device = Device.find(params[:id])
    authorize_action_for(@device)
    edit!
  end

  def edit_down
    @device = Device.find(params[:id])
    authorize_action_for(@device)
    edit!
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