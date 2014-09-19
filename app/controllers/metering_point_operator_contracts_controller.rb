class MeteringPointOperatorContractsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js

  def new
    @metering_point_operator_contract = MeteringPointOperatorContract.new
    #authorize_action_for @metering_point_operator_contract
    new!
  end

  def create
    create! do |format|
      @metering_point_operator_contract = MeteringPointOperatorContract.new(@metering_point_operator_contract)
    end
  end

  def edit
    @metering_point_operator_contract = MeteringPointOperatorContract.find(params[:id])
    #authorize_action_for @metering_point_operator_contract
    edit!
  end

protected
  def permitted_params
    params.permit(:metering_point_operator_contract => init_permitted_params)
  end

private
  def meter_params
    params.require(:metering_point_operator_contract).permit(init_permitted_params)
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