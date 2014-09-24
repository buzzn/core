class MetersController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js

  def new
    @meter = Meter.new
    authorize_action_for(@meter)
    new!
  end

  def edit
    @meter = Meter.find(params[:id])
    authorize_action_for(@meter)
    edit!
  end

  def update
    update! do |format|
      @meter = MeterDecorator.new(@meter)
    end
  end

  def create
    create! do |format|
      @meter = MeterDecorator.new(@meter)
    end
  end


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
      :manufacturer_product_name,
      :manufacturer_product_serialnumber,
      :virtual,
      registers_attributes: [:id, :mode, :obis_index, :variable_tariff, :_destroy, :metering_point_id],
      equipments_attributes: [:id, :manufacturer_name, :manufacturer_product_name, :manufacturer_product_serialnumber, :device_kind, :device_type, :ownership, :build, :calibrated_till, :converter_constant, :_destroy, :meter_id]
    ]
  end
end