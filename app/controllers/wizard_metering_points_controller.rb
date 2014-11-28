class WizardMeteringPointsController  < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js

  def metering_point
    @metering_point = MeteringPoint.new
  end

  def metering_point_update
    if location_params[:location_id]
      @location = Location.find(location_params[:location_id])
    end
    if permitted_params[:parent_metering_point_id]
      @parent_metering_point = MeteringPoint.find(permitted_params[:parent_metering_point_id])
    end
    @metering_point           = MeteringPoint.new(metering_point_params)
    if !@metering_point.save       #save already here for preventing raise of errors when assigning @metering_point to @location
      render action: 'metering_point'
      return
    end
    if @parent_metering_point
      @metering_point.parent = @parent_metering_point
      if @metering_point.save
        redirect_to meter_wizard_metering_points_path(metering_point_id: @metering_point.id, location_id: location_params[:location_id])
      else
        render action: 'metering_point'
      end
    else
      @location.metering_point = @metering_point
      if @location.save
        redirect_to meter_wizard_metering_points_path(metering_point_id: @metering_point.id, location_id: location_params[:location_id])
      else
        render action: 'metering_point'
      end
    end
  end


  def meter
    if params[:metering_point_id]
      @metering_point = MeteringPoint.find(params[:metering_point_id])
    end
    if @metering_point
      @meter = Meter.new
      @meter.registers << Register.new
    end
  end

  def meter_update
    if params[:metering_point_id]
      @metering_point = MeteringPoint.find(params[:metering_point_id])
    end
    if @metering_point
      @meter = Meter.new(meter_params)
      if @meter.save
        flash[:notice] = t('metering_point_created_successfully')
        render action: 'update'
      else
        render action: 'meter'
      end
    end
  end

  private

    def metering_point_params
      params.require(:metering_point).permit( :uid, :mode, :address_addition, :virtual, :metering_point_id, :parent_metering_point_id )
    end

    def meter_params
      params.require(:meter).permit(:id, :metering_point_id, :meter_id, :manufacturer_name, :manufacturer_product_name, :manufacturer_product_serialnumber, :owner, :mode, :meter_size, :rate, :measurement_capture, :mounting_method, :build_year, :calibrated_till, :smart, :virtual, registers_attributes: [:id, :metering_point_id, :mode, :obis_index, :variable_tariff, :_destroy])
    end

    def location_params
      params.permit(:location_id)
    end

    def permitted_params
      params.permit(:metering_point_id, :parent_metering_point_id)
    end



end


