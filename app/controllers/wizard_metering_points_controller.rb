class WizardMeteringPointsController  < ApplicationController
  before_filter :authenticate_user!

  def metering_point
    @location = Location.with_role(:manager, current_user).last
    @metering_point = MeteringPoint.new
  end

  def metering_point_update
    @location = Location.with_role(:manager, current_user).last
    @metering_point           = MeteringPoint.new(metering_point_params)
    @location.metering_points << @metering_point
    if @location.save
      redirect_to meter_wizard_metering_points_path(metering_point_id: @metering_point.id)
    else
      render action: 'metering_point'
    end
  end


  def meter
    @location = Location.with_role(:manager, current_user).last
    if @location.metering_points.empty?
      redirect_to action: 'metering_point'
    else
      @metering_point = @location.metering_points.last
      @meter = Meter.new
      @meter.registers << Register.new
    end
  end

  def new_meter_update
    @location = Location.with_role(:manager, current_user).last
    if @location.metering_points.empty?
      redirect_to action: 'metering_point'
    else
      @metering_point = @location.metering_points.last
      @meter = Meter.new(meter_params)
      if @meter.save
        redirect_to @location
      else
        render action: 'metering_point'
      end
    end
  end

  private

  def metering_point_params
    params.require(:metering_point).permit( :uid, :mode, :address_addition )
  end

  def meter_params
    params.require(:meter).permit(:id, :metering_point_id, :meter_id, :manufacturer_name, :manufacturer_product_name, :manufacturer_product_serialnumber, :owner, :mode, :meter_size, :rate, :measurement_capture, :mounting_method, :build_year, :calibrated_till, :smart, :virtual, registers_attributes: [:id, :metering_point_id, :mode, :obis_index, :variable_tariff, :_destroy])
  end

end


