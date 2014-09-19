class ElectricitySupplierContractsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js


  def new
    @electricity_supplier_contract              = ElectricitySupplierContract.new
    @electricity_supplier_contract.bank_account = BankAccount.new
    @electricity_supplier_contract.address      = Address.new
    new!
  end

  def update
    update! do |format|
      @electricity_supplier_contract = ElectricitySupplierContractDecorator.new(@electricity_supplier_contract)
    end
  end


protected
  def permitted_params
    params.permit(:electricity_supplier_contract => init_permitted_params)
  end

private
  def electricity_supplier_contract_params
    params.require(:electricity_supplier_contract).permit(init_permitted_params)
  end

  def init_permitted_params
    [
      :tariff,
      :price_cents,
      :status,
      :forecast_watt_hour_pa,
      :commissioning,
      :termination,
      :terms,
      :confirm_pricing_model,
      :power_of_attorney,
      :signing_user,
      :customer_number,
      :contract_number,
      :metering_point_id,
      :organization_id,
      address_attributes: [:id, :street, :city, :state, :zip, :country, :_destroy],
      bank_account_attributes: [:id, :holder, :iban, :bic, :_destroy]
    ]
  end



end