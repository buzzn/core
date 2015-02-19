class ContractsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js


  def new
    @contract              = Contract.new
    @contract.bank_account = BankAccount.new
    @contract.address      = Address.new
    authorize_action_for @contract
  end


  def create
    @contract = Contract.new(contract_params)
    authorize_action_for @contract
    if @contract.save
      current_user.add_role :manager, @contract
      @contract.decorate
    else
      render :new
    end
  end



private
  def contract_params
    params.require(:contract).permit(
      :mode,
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
      )
  end


end