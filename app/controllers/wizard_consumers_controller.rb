class WizardConsumersController  < ApplicationController
  before_filter :authenticate_user!


  def complete_user
    @profile = current_user.profile
  end

  def complete_user_update
    @profile = current_user.profile
    if @profile.update_attributes(profile_params)
      redirect_to action: 'contracting_party_legal_entity'
    else
      render action: 'complete_user'
    end
  end




  def contracting_party_legal_entity
    if current_user.contracting_party
      @contracting_party = current_user.contracting_party
    else
      @contracting_party = ContractingParty.new
    end
  end

  def contracting_party_legal_entity_update
    if current_user.contracting_party
      @contracting_party = current_user.contracting_party
      if @contracting_party.update_attributes(contracting_party_params)
        if @contracting_party.private?
          redirect_to action: 'location_address'
        else
          redirect_to action: 'contracting_party_organization'
        end
      else
        render action: 'contracting_party_legal_entity'
      end
    else
      @contracting_party = ContractingParty.new(contracting_party_params)
      @contracting_party = current_user.contracting_party
      if @contracting_party.save
        if @contracting_party.private?
          redirect_to action: 'location_address'
        else
          redirect_to action: 'contracting_party_organization'
        end
      else
        render action: 'contracting_party_legal_entity'
      end
    end
  end






  def contracting_party_address
    if current_user.contracting_party.address
      @address = current_user.contracting_party.address
    else
      @address = Address.new
    end
  end

  def contracting_party_address_update
    if current_user.contracting_party.address
      @address = current_user.contracting_party.address
      if @address.update!(address_params)
        redirect_to action: 'location_address'
      else
        render action: 'contracting_party_address'
      end
    else
      @address                    = Address.new(address_params)
      @address.contracting_party  = current_user.contracting_party
      if @address.save
        redirect_to action: 'location_address'
      else
        render action: 'contracting_party_address'
      end
    end
  end




  def contracting_party_organization
    if current_user.contracting_party.organization
      @organization = current_user.contracting_party.organization
    else
      @organization = Organization.new
    end
  end

  def contracting_party_organization_update
    if current_user.contracting_party.organization
      @organization = current_user.contracting_party.organization
      if @organization.update_attributes(organization_params)
        redirect_to action: 'contracting_party_organization_address'
      else
        render action: 'contracting_party_organization'
      end
    else
      @organization                   = Organization.new(organization_params)
      @organization.contracting_party = current_user.contracting_party
      if @organization.save
        redirect_to action: 'contracting_party_organization_address'
      else
        render action: 'contracting_party_organization'
      end
    end
  end


  def contracting_party_organization_address
    if current_user.contracting_party.organization.address
      @address = current_user.contracting_party.organization.address
    else
      @address = Address.new
    end
  end

  def contracting_party_organization_address_update
    if current_user.contracting_party.organization.address
      @address = current_user.contracting_party.organization.address
      if @address.update_attributes(address_params)
        redirect_to action: 'location_address'
      else
        render action: 'contracting_party_organization_address'
      end
    else
      @address = Address.new(address_params)
      if @address.valid?
        current_user.contracting_party.organization.address = @address
        if @address.save
          redirect_to action: 'location_address'
        else
          render action: 'contracting_party_organization_address'
        end
      else
        render action: 'contracting_party_organization_address'
      end
    end
  end


  def location_address
    if Location.with_role(:manager, current_user).to_a.count == 0    # TODO works with .to_a way ????
      @location = Location.new
      @location.build_address
    else
      @location = Location.with_role(:manager, current_user).last
    end
  end

  def location_address_update
    if Location.with_role(:manager, current_user).to_a.count == 0    # TODO works with .to_a way ????
      @location = Location.new(location_params)
      if @location.save
        current_user.add_role :manager, @location
        redirect_to action: 'location_habitation'
      else
        render action: 'location_address'
      end
    else
      @location = Location.with_role(:manager, current_user).last
      if @location.update_attributes(location_params)
        redirect_to action: 'location_habitation'
      else
        render action: 'location_address'
      end
    end
  end



  def location_habitation
    @location = Location.with_role(:manager, current_user).last
  end

  def location_habitation_update
    @location = Location.with_role(:manager, current_user).last
    if @location.update_attributes(location_params)
      redirect_to action: 'location_metering_point'
    else
      render action: 'location_habitation'
    end
  end





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
      @metering_point = MeteringPoint.new(metering_point_params)
      @metering_point.mode = 'down_metering'
      @location.metering_points << @metering_point
      if @location.save
        if @location.new_habitation
          redirect_to action: 'contract_forecast'
        else
          redirect_to action: 'metering_point_current_supplier'
        end
      else
        render action: 'location_metering_point'
      end
    else
      @metering_point = @location.metering_points.last
      if @metering_point.update_attributes(metering_point_params)
        if @location.new_habitation
          redirect_to action: 'contract_forecast'
        else
          redirect_to action: 'metering_point_current_supplier'
        end
      else
        render action: 'location_metering_point'
      end
    end
  end



  def metering_point_current_supplier
    @location = Location.with_role(:manager, current_user).last
    @metering_point = @location.metering_points.last
    if @metering_point.electricity_supplier_contract
      @electricity_supplier_contract = @metering_point.electricity_supplier_contract
    else
      @electricity_supplier_contract = ElectricitySupplierContract.new
    end
  end

  def metering_point_current_supplier_update
    @location = Location.with_role(:manager, current_user).last
    @metering_point = @location.metering_points.last
    if @metering_point.electricity_supplier_contract
      @electricity_supplier_contract = @metering_point.electricity_supplier_contract
      if @electricity_supplier_contract.update_attributes(electricity_supplier_contract_params)
        redirect_to action: 'contracting_party_bank_account'
      else
        render action: 'metering_point_current_supplier'
      end
    else
      @metering_point.electricity_supplier_contract = ElectricitySupplierContract.new(electricity_supplier_contract_params)
      if @metering_point.electricity_supplier_contract.save
        redirect_to action: 'contracting_party_bank_account'
      else
        render action: 'metering_point_current_supplier'
      end
    end
  end



  def contract_forecast
  end

  def contract_forecast_update
  end




  def contracting_party_bank_account
    if current_user.contracting_party.bank_account
      @bank_account = current_user.contracting_party.bank_account
    else
      @bank_account = BankAccount.new(holder: current_user.name)
    end
  end

  def contracting_party_bank_account_update
    if current_user.contracting_party.bank_account
      @bank_account = current_user.contracting_party.bank_account
      if @bank_account.update_attributes(bank_account_params)
        redirect_to action: 'complete_contract'
      else
        render action: 'contracting_party_bank_account'
      end
    else
      @bank_account = BankAccount.new(bank_account_params)
      if @bank_account.valid?
        current_user.contracting_party.bank_account = @bank_account
        if @bank_account.save
          redirect_to action: 'complete_contract'
        else
          render action: 'contracting_party_bank_account'
        end
      else
        render action: 'contracting_party_bank_account'
      end
    end
  end


  def complete_contract
    @location = Location.with_role(:manager, current_user).last
    @metering_point = @location.metering_points.last
    if @metering_point.contract
      @contract = @metering_point.contract
    else
      @contract = Contract.new
    end
  end

  def complete_contract_update
    @location = Location.with_role(:manager, current_user).last
    @metering_point = @location.metering_points.last
    if @metering_point.contract
      @contract                = @metering_point.contract
      @contract.update_attributes(contract_params)
    else
      @contract                 = Contract.new(contract_params)
    end
    @metering_point.contract    = @contract
    @contract.contracting_party = current_user.contracting_party
    if @contract.save
      redirect_to root_path
    else
      render action: 'complete_contract'
    end
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
    params.require(:contract).permit( :forecast_wh_pa, :terms, :confirm_pricing_model, :power_of_attorney )
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
