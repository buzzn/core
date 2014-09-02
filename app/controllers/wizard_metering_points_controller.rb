class WizardMeteringPointsController  < ApplicationController
  before_filter :authenticate_user!

  def new_metering_point
    @location = Location.with_role(:manager, current_user).last
    if @location.metering_points.empty?
      @metering_point = MeteringPoint.new
    else
      @metering_point = @location.metering_points.last
    end
  end

  def new_metering_point_update
    @location = Location.with_role(:manager, current_user).last
    if @location.metering_points.empty?
      @metering_point           = MeteringPoint.new(metering_point_params)
      @location.metering_points << @metering_point
      if @location.save
        redirect_to action: 'new_meter'
      else
        render action: 'new_metering_point'
      end
    else
      @metering_point = @location.metering_points.last
      if @metering_point.update_attributes(metering_point_params)
        redirect_to action: 'new_meter'
      else
        render action: 'new_metering_point'
      end
    end
  end


  def new_meter
    @location = Location.with_role(:manager, current_user).last
    if @location.metering_points.empty?
      redirect_to action: 'new_metering_point'
    else
      @metering_point = @location.metering_points.last
      if @metering_point.meter
        @meter = @metering_point.meter
      else
        @meter = Meter.new
      end
      if !@metering_point.registers.empty?
        @register = @metering_point.registers.last
      else
        @register = Register.new
      end
    end
  end

  def new_meter_update
    @location = Location.with_role(:manager, current_user).last
    if @location.metering_points.empty?
      redirect_to action: 'new_metering_point'
    else
      @metering_point = @location.metering_points.last
      if @metering_point.meter
        @meter = @metering_point.meter
        if !@meter.update_attributes(meter_params)
          render action: 'new_meter'
        end
      else
        @meter = Meter.new(meter_params)
      end
      if !@metering_point.registers.empty?
        @register = @metering_point.registers.last
        if !@register.update_attributes(register_params)
          render action: 'new meter'
        end
      else
        @register = Register.new(register_params)
      end
      @meter.registers << @register
      @metering_point.registers << @register
      if @meter.save and @register.save and @metering_point.save
        redirect_to current_user.profile
      else
        render action: 'new_metering_point'
      end
    end
  end

  private

  def metering_point_params
    params.require(:metering_point).permit( :uid, :mode, :address_addition )
  end

  def meter_params
    params.require(:meter).permit(:manufacturer_name, :manufacturer_product_name, :manufacturer_product_serialnumber, :owner, :mode, :meter_size, :rate, :measurement_capture, :mounting_method, :build_year, :calibrated_till, :smart, :virtual)
  end

  def register_params
    params.require(:register).permit(:mode, :obis_index, :variable_tariff, :predecimal_places, :decimal_places)
  end

end


