class AfterSignupController < ApplicationController
  before_filter :authenticate_user!

  include Wicked::Wizard

  steps :complete_user,
        :contracting_party,
        :location_address,
        :location_new_enter,
        :location_metering_point,
        :metering_point_current_supplier,
        :metering_point_contract,
        :contract_forecast_wh_pa,
        :contracting_party_bank_account,
        :contract_power_of_attorney




  def show
    @user = current_user
    case step
    when :contracting_party
      @contracting_party = ContractingParty.new
    end
    render_wizard
  end



  def update
    @user = current_user
    case step
    when :complete_user

    when :contracting_party
      @contracting_party.update_attributes(params[:user])

    when :confirm_password
      @user.update_attributes(params[:user])
    end

    render_wizard @user
  end




private

  def metering_point_params
    params.require(:metering_point).permit(MeteringPointsController.init_permitted_params)
  end





  # stromanbiter wechsel oder mit free account weiter

  # wenn stromanbiter wechsle dann
  # current_user vervollstadigung

  # current_user.contracting_party.new
    # Address.new

  # Location informtion anfragen
    # Address.new fildwith with current_user.contracting_party.address
    # Neu benzug?
    # MeteringPoint new
      # Meter abfragen
      # Aktuellen ElectricitySupplierContract abfragen

      # Contract new
        # connect with current_user.contracting_party
        # forecast_wh_pa

    # current_user.contracting_party.back_account.new
    # wenn nötig auch contract.bank_account.new

    # contract.power_of_attorney
    #

end
