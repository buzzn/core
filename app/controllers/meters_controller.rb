class MetersController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js


  def show
    @meter = Meter.find(params[:id]).decorate
    authorize_action_for(@meter)
  end



  def new
    @meter = Meter.new
    authorize_action_for(@meter)
  end

  def create
    @meter = Meter.new(meter_params)
    authorize_action_for @meter
    if @meter.save
      respond_with @meter.decorate
    else
      render :new
    end
  end



  def edit
    @meter = Meter.find(params[:id])
    authorize_action_for(@meter)
  end

  def update
    @meter = Meter.find(params[:id])
    authorize_action_for @meter
    if @meter.update_attributes(meter_params)
      respond_with @meter
    else
      render :edit
    end
  end





private
  def meter_params
    params.require(:meter).permit(
      :id,
      :image,
      :metering_point_id,
      :manufacturer_name,
      :manufacturer_product_name,
      :manufacturer_product_serialnumber,
      :virtual,
      registers_attributes: [:id, :mode, :obis_index, :variable_tariff, :_destroy, :metering_point_id, :virtual, :formula]
    )
  end






end