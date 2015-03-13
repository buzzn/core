class ContractingPartiesController < ApplicationController
  before_filter :authenticate_user!


  def show
    @contracting_party = ContractingParty.find(params[:id]).decorate
  end

  def new
    @contracting_party              = ContractingParty.new
    @contracting_party.bank_account = BankAccount.new
    @contracting_party.address      = Address.new
    @contracting_party.organization = Organization.new
  end


  def create
    @contracting_party = ContractingParty.new(contracting_party_params)
    authorize_action_for @contracting_party
    if @contracting_party.save
      current_user.add_role :manager, @contracting_party
      @contracting_party.decorate
    else
      render :new
    end
  end


  def edit
    @contracting_party = ContractingParty.find(params[:id])
    authorize_action_for @contracting_party
  end




  def update
    @contracting_party = ContractingParty.find(params[:id])
    authorize_action_for @contracting_party
    if @contracting_party.update_attributes(contracting_party_params)
      respond_with @contracting_party
    else
      render :edit
    end
  end


  def destroy
    @contracting_party = ContractingParty.find(params[:id])
    @contracting_party.destroy
    redirect_to current_user.profile
  end


private
  def contracting_party_params
    params.require(:contracting_party).permit(
      :legal_entity,
      organization_attributes: [:id, :image, :name, :email, :phone, :_destroy]
      )
  end



end
