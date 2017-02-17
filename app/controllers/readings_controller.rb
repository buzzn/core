class ReadingsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js

  def new
    @reading = Reading.new
  end

  def create
    date = Date.new params[:reading]["timestamp(1i)"].to_i, params[:reading]["timestamp(2i)"].to_i, params[:reading]["timestamp(3i)"].to_i
    @register = Register::Base.find(params[:reading][:register_id])
    @reading = Reading.new(register_id: @register.id, timestamp: date, energy_milliwatt_hour: params[:reading][:energy_milliwatt_hour])
    @reading.energy_milliwatt_hour *= 1000000
    @reading.source = 'user_input'
    if @reading.save
      @register.calculate_forecast
      flash[:notice] = t('reading_created_successfully')
      render :create
    else
      @reading.energy_milliwatt_hour *= 0.000001
      render :new, errors: @reading.errors.full_messages, register_id: @register.id
    end
  end

  def destroy
    @reading = Reading.find(params[:id])
    @register = Register::Base.find(@reading[:register_id])
    if @reading.destroy
      @register.calculate_forecast
      flash[:notice] = t('reading_deleted_successfully')
      redirect_to register_path(@register)
    else
      flash[:error] = t('failed_to_delete_reading')
      redirect_to register_path(@register)
    end
  end


private
  def reading_params
    params.require(:reading).permit(
      :timestamp,
      :energy_milliwatt_hour,
      :register_id
      )
  end

end