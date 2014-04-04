class ContractsController < InheritedResources::Base
  before_filter :authenticate_user!

  def new
    @contract = Contract.new(signing_user: current_user.name)
    @contract.bank_account = BankAccount.new
    @contract.address = Address.new
    new!
  end

  def permitted_params
    params.permit(:contracting_party => [
      :metering_point,
      :signing_user,
      :terms,
      :confirm_pricing_model,
      :power_of_attorney,
      bank_account_attributes: [:id, :holder, :iban, :bic, :_destroy],
      address_attributes: [:id, :street, :city, :state, :zip, :country, :_destroy]
      ])
  end


end