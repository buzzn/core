class ReadingsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js

  def new
    @reading = Reading.new
  end

  def create
    @reading = Reading.new(reading_params)
    @reading.watt_hour *= 10000000000
    @reading.source = 'user_input'
    if @reading.save
      render :create
    else
      render :new
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