require_relative '../billing'
require_relative '../../../schemas/transactions/admin/billing/update'

class Transactions::Admin::Billing::Update < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update'
  tee :check_status
  around :db_transaction
  tee :execute_transistion
  map :persist, with: :'operations.action.update'

  include Import[accounting_service: 'services.accounting']

  def schema
    Schemas::Transactions::Admin::Billing::Update
  end

  def check_status(resource:, params:)
    if !params[:status].nil? && !resource.object.allowed_transitions.map(&:to_s).include?(params[:status])
      # not allowed
      raise Buzzn::ValidationError.new(status: "transition from #{resource.object.status} to #{params[:status]} is not possible")
    end
  end

  def execute_transistion(resource:, params:)
    user = resource.security_context.current_user
    billing = resource.object
    contract = billing.contract
    action = billing.transition_to(params.delete(:status))
    # transition may only continue if invariant are clean
    unless billing.invariant.errors.empty?
      return
    end

    case action
    when :calculate
      # accounting is in decacents; 10dc = 1c
      total_amount = resource.object.total_amount*10
      params[:accounting_entry] = accounting_service.book(user, contract, -1 * total_amount.round)
    end
  end

end
