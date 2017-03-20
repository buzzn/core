class MetersController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js, :json


  def show
    @meter = Meter::Base.find(params[:id]).decorate
    authorize_action_for(@meter)
  end



  def new
    @meter = Meter::Base.new
    authorize_action_for(@meter)
  end

  def create
    @meter = Meter::Base.new(meter_params)
    authorize_action_for @meter
    if @meter.save
      current_user.add_role :manager, @meter
      respond_with @meter.decorate
    else
      render :new
    end
  end



  def edit
    @meter = Meter::Base.find(params[:id])
    authorize_action_for(@meter)
  end

  def update
    @meter = Meter::Base.find(params[:id])
    authorize_action_for @meter
    if @meter.update_attributes(meter_params)
      respond_with @meter
    else
      render :edit
    end
  end


  def destroy
    @meter = Meter::Base.find(params[:id])
    authorize_action_for @meter
    @meter.destroy
    respond_with current_user.profile
  end

  def validate
    @serial = !params[:register_base].nil? ? params[:register_base][meter_class(params[:register_base])][:manufacturer_product_serialnumber] : params[meter_class(params)][:manufacturer_product_serialnumber]
    render json: Meter::Base.where(manufacturer_product_serialnumber: @serial).empty?
  end




private

  def meter_class(parameters)
    if parameters[:meter_base].nil? && !parameters[:meter_real].nil? && parameters[:meter_virtual].nil?
      :meter_real
    elsif parameters[:meter_base].nil? && parameters[:meter_real].nil? && !parameters[:meter_virtual].nil?
      :meter_virtual
    elsif !parameters[:meter_base].nil? && parameters[:meter_virtual] && parameters[:meter_real].nil?
      :meter_base
    end
  end

  def meter_params
    params.require(meter_class(params)).permit(
      :image,
      :manufacturer_name,
      :manufacturer_product_name,
      :manufacturer_product_serialnumber,
      :virtual,
      :register_ids => []
    )
  end






end
