class WizardMeteringPointsController  < ApplicationController
  before_filter :authenticate_user!

  def location_metering_point
    @location = Location.with_role(:manager, current_user).last
    if @location.metering_points.empty?
      @metering_point = MeteringPoint.new
    else
      @metering_point = @location.metering_points.last
    end
  end

  def location_metering_point_update
    @location = Location.with_role(:manager, current_user).last
    if @location.metering_points.empty?
      @metering_point           = MeteringPoint.new(metering_point_params)
      @location.metering_points << @metering_point
      if @location.save
        redirect_to action: 'meter'
      else
        render action: 'location_metering_point'
      end
    else
      @metering_point = @location.metering_points.last
      if @metering_point.update_attributes(metering_point_params)
        redirect_to action: 'meter'
      else
        render action: 'location_metering_point'
      end
    end
  end


  def new_meter
    @location = Location.with_role(:manager, current_user).last
    if @location.metering_points.empty?
      redirect_to action: 'location_metering_point'
    else
      @metering_point = @location.metering_points.last
    end
  end

  def new_meter_update
    @location = Location.with_role(:manager, current_user).last
    if @location.metering_points.empty?
      redirect_to action: 'location_metering_point'
    else
      @metering_point = @location.metering_points.last
      if @metering_point.meter
        redirect_to current_user.profile
      else
        @meter = Meter.new(meter_params)
        @metering_point.meter = @meter
        redirect_to current_user.profile
      end

      if @meter.update_attributes(meter_params)
        redirect_to current_user.profile
      else
        render action: 'location_metering_point'
      end

    end
  end


  private

  def metering_point_params
    params.require(:metering_point).permit( :uid, :mode, :address_addition )
  end

  def meter_params
    params.require(:meter).permit(:manufacturer_name, :manufacturer_product_name, :manufacturer_product_serial_number, :owner, :mode, :meter_size, :rate, :measurement_capture, :mounting_method, :build_year, :calibrated_till, :smart, :virtual)
  end

end

