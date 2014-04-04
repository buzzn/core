class ContractingPartiesController < InheritedResources::Base
  before_filter :authenticate_user!

  def new
    @contracting_party              = ContractingParty.new
    @contracting_party.bank_account = BankAccount.new
    @contracting_party.address      = Address.new
    @contracting_party.organization = Organization.new
    new!
  end


protected
  def permitted_params
    params.permit(contracting_party: init_permitted_params)
  end

private
  def meter_params
    params.require(:contracting_party).permit(init_permitted_params)
  end

  def init_permitted_params
    [
      :legal_entity, 
      bank_account_attributes: [:id, :holder, :iban, :bic, :_destroy],
      address_attributes: [:id, :street, :city, :state, :zip, :country, :_destroy],
      organization_attributes: [:id, :image, :name, :email, :phone, :_destroy]
    ]
  end




end
