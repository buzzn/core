class DistributionSystemOperatorContractsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js

  def new
    @distribution_system_cperator_contract = DistributionSystemOperatorContract.new
    authorize_action_for @distribution_system_cperator_contract
    new!
  end

  def edit
    @distribution_system_cperator_contract = DistributionSystemOperatorContract.find(params[:id])
    authorize_action_for @distribution_system_cperator_contract
    edit!
  end

protected
  def permitted_params
    params.permit(:distribution_system_operator_contract => init_permitted_params)
  end

private
  def meter_params
    params.require(:distribution_system_operator_contract).permit(init_permitted_params)
  end

  def init_permitted_params
    [
      :edifact_email,
      :contact_name,
      :contact_email
    ]
  end
end