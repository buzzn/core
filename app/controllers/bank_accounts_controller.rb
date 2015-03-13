class BankAccountsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js


  def show
    @bank_account = BankAccount.find(params[:id]).decorate
    authorize_action_for(@bank_account)
  end



  def new
    @bank_account = BankAccount.new
    authorize_action_for(@bank_account)
  end

  def create
    @bank_account = BankAccount.new(bank_account_params)
    authorize_action_for @bank_account
    if @bank_account.save
      respond_with @bank_account.decorate
    else
      render :new
    end
  end



  def edit
    @bank_account = BankAccount.find(params[:id])
    authorize_action_for(@bank_account)
  end


  def update
    @bank_account = BankAccount.find(params[:id])
    authorize_action_for @bank_account
    if @bank_account.update_attributes(bank_account_params)
      respond_with @bank_account
    else
      render :edit
    end
  end


  def destroy
    @bank_account = BankAccount.find(params[:id])
    authorize_action_for @bank_account
    @bank_account.destroy
    respond_with current_user.profile
  end


private
  def bank_account_params
    params.require(:bank_account).permit(
      :holder,
      :iban,
      :bic,
      :bank_name,
      :direct_debit,
      :bank_accountable_id,
      :bank_accountable_type
    )
  end


end