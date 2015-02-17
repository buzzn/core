class RegistersController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js

  def show
    @register = Register.find(params[:id]).decorate
    authorize_action_for @register
  end

  def new
    @register = Register.new
    authorize_action_for @register
  end


  def create
    @register = Register.new(register_params)
    authorize_action_for @register
    if @register.save
      @register.decorate
    else
      render :edit
    end
  end


  def edit
    @register = Register.find(params[:id]).decorate
    authorize_action_for @register
  end


  def update
    @register = Register.find(params[:id]).decorate
    authorize_action_for @register
    if @register.update_attributes(register_params)
      @register.decorate
    else
      render :edit
    end
  end





private
  def register_params
    params.require(:register).permit(:mode, :obis_index, :variable_tariff, :virtual, :formula, :meter_id, :metering_point_id)
  end

end



