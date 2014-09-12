class MeteringServiceProviderContractsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js

  def new
    @metering_service_provider_contract = MeteringServiceProviderContract.new
    #authorize_action_for @metering_service_provider_contract
    new!
  end

  def edit
    @metering_service_provider_contract = MeteringServiceProviderContract.find(params[:id])
    #authorize_action_for @metering_service_provider_contract
    edit!
  end

protected
  def permitted_params
    params.permit(:metering_service_provider_contract => init_permitted_params)
  end

private
  def meter_params
    params.require(:metering_service_provider_contract).permit(init_permitted_params)
  end

  def init_permitted_params
    [
      :customer_number,
      :contract_number,
      :username,
      :password,
      :metering_point_id,
      :organisation_id
    ]
  end
end