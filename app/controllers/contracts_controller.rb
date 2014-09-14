class ContractsController < InheritedResources::Base
  respond_to :html, :js
  before_filter :authenticate_user!

  def new
    @contract              = Contract.new
    @contract.bank_account = BankAccount.new
    @contract.address      = Address.new
    new!
  end

  def update
    update! do |format|
      @contract = ContractDecorator.new(@contract)
    end
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
      :contracting_party_id,
      :metering_point,
      :status,
      :price_cents,
      :signing_user,
      :terms,
      :confirm_pricing_model,
      :power_of_attorney,
      :commissioning,
      :termination,
      :forecast_watt_hour_pa,
      :mode,
      address_attributes: [:id, :street, :city, :state, :zip, :country, :_destroy],
      bank_account_attributes: [:id, :holder, :iban, :bic, :_destroy]
    ]
  end


end







