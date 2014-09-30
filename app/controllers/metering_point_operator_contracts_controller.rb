class MeteringPointOperatorContractsController < InheritedResources::Base
  before_filter :authenticate_user!
  respond_to :html, :js

  def new
    @metering_point_operator_contract = MeteringPointOperatorContract.new
    #authorize_action_for @metering_point_operator_contract
    new!
  end

  def create
    create! do |success, failure|
      @metering_point_operator_contract = MeteringPointOperatorContractDecorator.new(@metering_point_operator_contract)
      success.js { @metering_point_operator_contract }
      failure.js { render :new }
    end
  end

  def edit
    edit! do |format|
      @metering_point_operator_contract = MeteringPointOperatorContractDecorator.new(@metering_point_operator_contract)
    end
  end



protected
  def permitted_params
    params.permit(:metering_point_operator_contract => init_permitted_params)
  end

private
  def metering_point_operator_contract_params
    params.require(:metering_point_operator_contract).permit(init_permitted_params)
  end

  def init_permitted_params
    [
      :id,
      :customer_number,
      :contract_number,
      :username,
      :password,
      :metering_point_id,
      :organization_id,
      :group_id
    ]
  end
end