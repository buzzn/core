class ElectricitySupplierContractsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js

  def new
    @electricity_supplier_contract = ElectricitySupplierContract.new
    authorize_action_for @electricity_supplier_contract
    new!
  end

  def edit
    @electricity_supplier_contract = ElectricitySupplierContract.find(params[:id])
    authorize_action_for @electricity_supplier_contract
    edit!
  end

protected
  def permitted_params
    params.permit(:electricity_supplier_contract => init_permitted_params)
  end

private
  def meter_params
    params.require(:electricity_supplier_contract).permit(init_permitted_params)
  end

  def init_permitted_params
    [
      :customer_number,
      :contract_number,
      :pdf
    ]
  end
end