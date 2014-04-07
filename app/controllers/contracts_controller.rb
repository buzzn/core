class ContractsController < InheritedResources::Base
  before_filter :authenticate_user!

  def new
    @contract                   = Contract.new
    @contract.bank_account      = BankAccount.new
    @contract.address           = Address.new
    @contract.external_contracts << ExternalContract.new(mode: 'distribution_system_operator')
    @contract.external_contracts << ExternalContract.new(mode: 'metering_service_provider')
    @contract.external_contracts << ExternalContract.new(mode: 'electricity_supplier')
    new!
  end



protected
  def permitted_params
    params.permit(:contract => init_permitted_params)
  end

private
  def meter_params
    params.require(:contract).permit(init_permitted_params)
  end

  def init_permitted_params
    [
      :metering_point,
      :signing_user,
      :terms,
      :confirm_pricing_model,
      :power_of_attorney,
      address_attributes: [:id, :street, :city, :state, :zip, :country, :_destroy],
      bank_account_attributes: [:id, :holder, :iban, :bic, :_destroy],
      external_contract_attributes: [:id, :mode, :customer_number, :contract_number, :_destroy]
    ]
  end


end