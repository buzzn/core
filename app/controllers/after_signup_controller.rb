class AfterSignupController < ApplicationController
  before_filter :authenticate_user!

  include Wicked::Wizard

  steps :complete_user,
        :contracting_party_legal_entity,
        :contracting_party_organization,
        :contracting_party_organization_address,
        :location_address,
        :location_habitation,
        :location_metering_point,
        :metering_point_current_supplier,
        :contract_forecast,
        :contracting_party_bank_account,
        :complete_contract


  def show
    case step
    when :complete_user
      @profile = current_user.profile

    when :contracting_party_legal_entity
      if current_user.contracting_party
        @contracting_party = current_user.contracting_party
      else
        @contracting_party = ContractingParty.new
      end

    when :contracting_party_organization
      if current_user.contracting_party && current_user.contracting_party.organization
        @organization = current_user.contracting_party.organization
      else
        @organization = Organization.new
      end

    when :contracting_party_organization_address
      if current_user.contracting_party && current_user.contracting_party.organization.address
        @address = current_user.contracting_party.organization.address
      else
        @address = Address.new
      end

    when :location_address
      @locations = Location.with_role(:manager, current_user)

      if @locations.size == 0    # TODO works with .to_a way ????
        @location = Location.new
        @location.build_address
      else
        @location = @locations.last
      end

    when :location_habitation
      @locations = Location.with_role(:manager, current_user)
      @location = @locations.last

    when :location_metering_point
      @locations = Location.with_role(:manager, current_user)
      @location = @locations.last
      if @location.metering_points.empty?
        @metering_point = MeteringPoint.new
      else
        @metering_point = @location.metering_points.last
      end

    when :metering_point_current_supplier
      @locations = Location.with_role(:manager, current_user)
      @location = @locations.last
      @metering_point = @location.metering_points.last
      if @metering_point.electricity_supplier_contract
        @electricity_supplier_contract = @metering_point.electricity_supplier_contract
      else
        @electricity_supplier_contract = ElectricitySupplierContract.new
      end

    when :contract_forecast
      @locations = Location.with_role(:manager, current_user)
      @location = @locations.last
      @metering_point = @location.metering_points.last
      if @metering_point.contract
        @contract = @metering_point.contract
      else
        @contract = Contract.new
      end

    when :contracting_party_bank_account
      if current_user.contracting_party.bank_account
        @bank_account = current_user.contracting_party.bank_account
      else
        @bank_account = BankAccount.new(holder: current_user.name)
      end

    when :complete_contract
      @locations = Location.with_role(:manager, current_user)
      @location = @locations.last
      @metering_point = @location.metering_points.last
      if @metering_point.contract
        @contract = @metering_point.contract
      else
        @contract = Contract.new
      end


    end
    render_wizard
  end



  def update
    case step


    when :complete_user
      current_user.profile.update!(profile_params)


    when :contracting_party_legal_entity
      if current_user.contracting_party
        @contracting_party = current_user.contracting_party
        @contracting_party.update!(contracting_party_params)
      else
        @contracting_party = current_user.contracting_party = ContractingParty.new(contracting_party_params)
      end
      if @contracting_party.legal_entity == 'me'
        skip_step
      end


    when :contracting_party_organization
      if current_user.contracting_party.organization
        @organization = current_user.contracting_party.organization
        @organization.update!(organization_params)
      else
        current_user.contracting_party.organization = Organization.new(organization_params)
        current_user.contracting_party.save
      end


    when :contracting_party_organization_address
      if current_user.contracting_party.organization.address
        current_user.contracting_party.organization.address.update!(address_params)
      else
        current_user.contracting_party.organization.address = Address.new(address_params)
        current_user.contracting_party.organization.save
      end


    when :location_address
      @locations = Location.with_role(:manager, current_user)
      if @locations.to_a.size == 0    # TODO works with .to_a way ????
        @location = Location.new(location_params)
        current_user.add_role :manager, @location
      else
        @location = @locations.last
        @location.update!(location_params)
      end


    when :location_habitation
      @locations = Location.with_role(:manager, current_user)
      @location = @locations.last
      @location.update!(location_params)


    when :location_metering_point
      @locations = Location.with_role(:manager, current_user)
      @location = @locations.last
      if @location.metering_points.empty?
        @location.metering_points << MeteringPoint.new(metering_point_params)
        @location.save
      else
        @metering_point = @location.metering_points.last
        @metering_point.update!(metering_point_params)
      end
      if @location.new_habitation
        jump_to(:contract_forecast)
      end


    when :metering_point_current_supplier
      @locations = Location.with_role(:manager, current_user)
      @location = @locations.last
      @metering_point = @location.metering_points.last
      if @metering_point.electricity_supplier_contract
        @metering_point.electricity_supplier_contract.update!(electricity_supplier_contract_params)
      else
        @metering_point.electricity_supplier_contract = ElectricitySupplierContract.new(electricity_supplier_contract_params)
        @metering_point.electricity_supplier_contract.save
      end


    when :contract_forecast
      @locations = Location.with_role(:manager, current_user)
      @location = @locations.last
      @metering_point = @location.metering_points.last
      if @metering_point.contract
        @metering_point.contract.update!(contract_params)
      else
        @metering_point.contract = Contract.new(contract_params)
        @metering_point.contract.save
      end


    when :contracting_party_bank_account
      if current_user.contracting_party.bank_account
        current_user.contracting_party.bank_account.update!(bank_account_params)
      else
        current_user.contracting_party.bank_account = BankAccount.new(bank_account_params)
        current_user.contracting_party.save
      end


    when :complete_contract
      @locations = Location.with_role(:manager, current_user)
      @location = @locations.last
      @metering_point = @location.metering_points.last
      if @metering_point.contract
        @contract = @metering_point.contract.update!(contract_params)
      else
        @contract = Contract.new(contract_params)
      end


    end
    render_wizard current_user
  end




private

  def profile_params
    params.require(:profile).permit(:image, :first_name, :last_name, :gender, :phone)
  end

  def contracting_party_params
    params.require(:contracting_party).permit(:legal_entity)
  end

  def organization_params
    params.require(:organization).permit(:image, :name, :email, :phone)
  end

  def address_params
    params.require(:address).permit(:street, :city, :state, :zip, :country)
  end

  def location_params
    params.require(:location).permit(:new_habitation, :inhabited_since, address_attributes: [:id, :street, :city, :state, :zip, :country])
  end

  def metering_point_params
    params.require(:metering_point).permit( :uid, :mode, :address_addition )
  end

  def electricity_supplier_contract_params
    params.require(:electricity_supplier_contract).permit( :customer_number, :contract_number, :forecast_wh_pa, :organization_id )
  end

  def contract_params
    params.require(:contract).permit( :forecast_wh_pa )
  end

  def bank_account_params
    params.require(:bank_account).permit( :holder, :iban, :bic, :bank_name, :direct_debit )
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
