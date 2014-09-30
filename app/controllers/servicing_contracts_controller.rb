class ServicingContractsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js

  def new
    @servicing_contract = ServicingContract.new
    #authorize_action_for @servicing_contract
    new!
  end

  def create
    create! do |success, failure|
      @servicing_contract = ServicingContractDecorator.new(@servicing_contract)
      success.js { @servicing_contract }
      failure.js { render :new }
    end
  end

  def edit
    edit! do |format|
      @servicing_contract = ServicingContractDecorator.new(@servicing_contract)
    end
  end



protected
  def permitted_params
    params.permit(:servicing_contract => init_permitted_params)
  end

private
  def servicing_contract_params
    params.require(:servicing_contract).permit(init_permitted_params)
  end

  def init_permitted_params
    [
      :id,
      :tariff,
      :status,
      :signing_user,
      :terms,
      :confirm_pricing_model,
      :power_of_attorney,
      :commissioning,
      :termination,
      :forecast_watt_hour_pa,
      :price_cents,
      :group_id,
      :organization_id
    ]
  end
end
