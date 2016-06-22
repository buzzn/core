class ReadingsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js

  def new
    @reading = Reading.new
  end

  def create
    date = Date.new params[:reading]["timestamp(1i)"].to_i, params[:reading]["timestamp(2i)"].to_i, params[:reading]["timestamp(3i)"].to_i
    @metering_point = MeteringPoint.find(params[:reading][:metering_point_id])
    @meter = @metering_point.meter
    @reading = Reading.new(meter_id: @meter.id, timestamp: date, energy_a_milliwatt_hour: params[:reading][:energy_a_milliwatt_hour])
    @reading.energy_a_milliwatt_hour *= 1000000
    @reading.source = 'user_input'
    if @reading.save
      @metering_point.calculate_forecast
      flash[:notice] = t('reading_created_successfully')
      render :create
    else
      @reading.energy_a_milliwatt_hour *= 0.000001
      render :new, errors: @reading.errors.full_messages, metering_point_id: @metering_point.id
    end
  end

  def destroy
    @reading = Reading.find(params[:id])
    @metering_point = MeteringPoint.find(@reading[:metering_point_id])
    if @reading.destroy
      @metering_point.calculate_forecast
      flash[:notice] = t('reading_deleted_successfully')
      redirect_to metering_point_path(@metering_point)
    else
      flash[:error] = t('failed_to_delete_reading')
      redirect_to metering_point_path(@metering_point)
    end
  end


private
  def reading_params
    params.require(:reading).permit(
      :timestamp,
      :energy_a_milliwatt_hour,
      :metering_point_id
      )
  end

end