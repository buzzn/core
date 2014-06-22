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
      :manufacturer_product_number,
      :manufacturer_device_number,
      :virtual,
      registers_attributes: [:id, :mode, :obis_index, :variable_tariff, :_destroy]
    ]
  end
end