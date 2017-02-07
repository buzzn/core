class ContractsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js

  def show
    @contract = Contract.find(params[:id]).decorate
    authorize_action_for(@contract)
  end


  def new
    @contract = Contract.new
    authorize_action_for @contract
  end


  def create
    @contract = Contract.new(contract_params)
    authorize_action_for @contract
    if @contract.organization.slug == 'buzzn-metering' ||
       @contract.organization.buzzn_metering?
      @contract.username = 'team@localpool.de'
      @contract.password = 'Zebulon_4711'
    end
    if @contract.save
      current_user.add_role :manager, @contract
      @contract.decorate
    else
      render :new
    end
  end


  def edit
    @contract = Contract.find(params[:id])
    authorize_action_for @contract
  end




  def update
    @contract = Contract.find(params[:id])
    authorize_action_for @contract
    if @contract.update_attributes(contract_params)
      respond_with @contract
    else
      render :edit
    end
  end


  def destroy
    @contract = Contract.find(params[:id])
    @contract.destroy
    redirect_to current_user.profile
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
      :username,
      :password,
      :register_id,
      :organization_id,
      :group_id,
      :contractor_id,
      :customer_id
      )
  end


end
