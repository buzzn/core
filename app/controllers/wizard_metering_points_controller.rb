class WizardMeteringPointsController  < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js

  def metering_point
    @metering_point = MeteringPoint.new
  end

  def metering_point_update
    @metering_point = MeteringPoint.new(metering_point_params)
    @metering_point.readable = 'friends'
    if @metering_point.save
      current_user.add_role(:manager, @metering_point)
      redirect_to meter_wizard_metering_points_path(metering_point_id: @metering_point.id)
    else
      render action: 'metering_point'
    end
  end


  def meter
    @metering_point = MeteringPoint.find(params[:metering_point_id])
    @meter = Meter.new
  end

  def meter_update
    @metering_point = MeteringPoint.find(params[:metering_point_id])
    @meter = Meter.new(meter_params)
    @meter.metering_points << @metering_point
    if @meter.save
      @metering_point.create_activity key: 'metering_point.create', owner: current_user
      if params[:meter][:smartmeter] == "Ja"
        redirect_to contract_wizard_metering_points_path(metering_point_id: @metering_point.id)
      else
        render action: 'update'
      end
    else
      render action: 'meter'
    end
  end

  def contract
    @metering_point = MeteringPoint.find(params[:metering_point_id])
    @contract = Contract.new
  end

  def contract_update
    @metering_point = MeteringPoint.find(params[:metering_point_id])
    @contract = Contract.new(contract_params)
    @contract.mode = 'metering_point_operator_contract'
    @contract.price_cents = 0
    @contract.metering_point = @metering_point
    if @contract.organization.slug == 'buzzn-metering'
      @contract.username = 'team@buzzn-metering.de'
      @contract.password = 'Zebulon_4711'
    end
    if @contract.save && @metering_point.meter.save
      render action: 'update'
    else
      render action: 'contract'
    end
  end

  private

  def metering_point_params
    params.require(:metering_point).permit( :name, :mode)
  end

  def meter_params
    params.require(:meter).permit(:id, :metering_point_id, :meter_id, :manufacturer_product_serialnumber)
  end

  def contract_params
    params.require(:contract).permit( :id, :organization_id, :username, :password)
  end

end