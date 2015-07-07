class ReadingsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js

  def new
    @reading = Reading.new
  end

  def create
    date = Date.new params[:reading]["timestamp(1i)"].to_i, params[:reading]["timestamp(2i)"].to_i, params[:reading]["timestamp(3i)"].to_i
    @reading = Reading.new(metering_point_id: params[:reading][:metering_point_id], timestamp: date, watt_hour: params[:reading][:watt_hour])
    @metering_point = MeteringPoint.find(@reading.metering_point_id)
    @reading.watt_hour *= 10000000000
    @reading.source = 'user_input'
    if @reading.save
      @metering_point.calculate_forecast
      flash[:notice] = t('reading_created_successfully')
      render :create
    else
      @reading.watt_hour *= 0.0000000001
      render :new, errors: @reading.errors.full_messages
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
      render :edit, errors: @reading.errors.full_messages
    end
  end


private
  def reading_params
    params.require(:reading).permit(
      :timestamp,
      :watt_hour,
      :metering_point_id
      )
  end

end