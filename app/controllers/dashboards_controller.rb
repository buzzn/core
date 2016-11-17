class DashboardsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js

  def show
    if user_signed_in?
      @dashboard = Dashboard.find(params[:id])
      @registers = @dashboard.registers
    else
      redirect_to new_user_session_path
    end
    authorize_action_for(@dashboard)
  end

  def add_register
    @dashboard = Dashboard.find(params[:id])
    authorize_action_for(@dashboard)
  end
  authority_actions :add_register => 'update'

  def add_register_update
    @dashboard = Dashboard.find(params[:id])
    @registers = Register.find(params[:dashboard][:registers].reject{|id| id.empty?})
    @registers.each do |register|
      if !@dashboard.registers.include?(register)
        @dashboard.registers << register
        @dashboard.save
      end
    end
    authorize_action_for(@dashboard)
  end
  authority_actions :add_register_update => 'update'

  def remove_register
    @dashboard = Dashboard.find(params[:dashboard_id])
    @register = Register.find(params[:register_id])
    if @dashboard.registers.include?(@register)
      @dashboard.registers.delete(@register)
      @dashboard.save
    end
    authorize_action_for(@dashboard)
  end
  authority_actions :remove_register => 'update'


  # def display_register_in_series
  #   @dashboard = Dashboard.find(params[:dashboard_id])
  #   @register = Register.find(params[:register_id])
  #   #@dashboard_register = @dashboard.dashboard_registers[params[:series].to_i - 1]
  #   #@operator = params[:operator]
  #   #@dashboard_register.formula_parts << FormulaPart.create(operator: @operator, register_id: @dashboard_register.id, operand_id: @register.id)
  #   @dashboard_register = DashboardRegister.where(dashboard_id: @dashboard.id, register_id: @register.id).first
  #   @dashboard_register.displayed = true
  #   @dashboard_register.save
  #   authorize_action_for(@dashboard)
  # end
  # authority_actions :display_register_in_series => 'update'


  # def remove_register_from_series
  #   @dashboard = Dashboard.find(params[:dashboard_id])
  #   @register = Register.find(params[:register_id])
  #   @dashboard_register = DashboardRegister.where(dashboard_id: @dashboard.id, register_id: @register.id).first
  #   @dashboard_register.displayed = false
  #   @dashboard_register.save
  #   authorize_action_for(@dashboard)
  # end
  # authority_actions :remove_register_from_series => 'update'

end