class WizardLocationsController  < ApplicationController
  before_filter :authenticate_user!


  def new_location
    @profile = current_user.profile
  end

  def new_location_update
    @profile = current_user.profile
    if @profile.update_attributes(profile_params)
      redirect_to action: 'contracting_party_legal_entity'
    else
      render action: 'complete_user'
    end
  end




  def new_metering_point
    if current_user.contracting_party
      @contracting_party = current_user.contracting_party
    else
      @contracting_party = ContractingParty.new
    end
  end

  def new_metering_point_update
    if current_user.contracting_party
      @contracting_party = current_user.contracting_party
      if @contracting_party.update_attributes(contracting_party_params)
        if @contracting_party.natural_person?
          redirect_to action: 'location_address'
        else
          redirect_to action: 'contracting_party_organization'
        end
      else
        render action: 'contracting_party_legal_entity'
      end
    else
      @contracting_party      = ContractingParty.new(contracting_party_params)
      @contracting_party.user = current_user
      if @contracting_party.save
        if @contracting_party.natural_person?
          redirect_to action: 'location_address'
        else
          redirect_to action: 'contracting_party_organization'
        end
      else
        render action: 'contracting_party_legal_entity'
      end
    end
  end
end