require_relative '../billing_cycle'
require_relative '../../../schemas/transactions/admin/billing_cycle/update'

class Transactions::Admin::BillingCycle::Update < Transactions::Base
  def self.for(billing_cycle)
    super(Schemas::Transactions::Admin::BillingCycle::Update, billing_cycle, :authorize, :persist)
  end

  step :validate, with: :'operations.validation'
  step :authorize, with: :'operations.authorization.update'
  step :persist, with: :'operations.action.update'
end
