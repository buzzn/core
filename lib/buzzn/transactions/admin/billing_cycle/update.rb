require_relative '../billing_cycle'
require_relative '../../../schemas/transactions/admin/billing_cycle/update'

class Transactions::Admin::BillingCycle::Update < Transactions::Base

  def self.for(billing_cycle)
    super(billing_cycle, :authorize, :persist)
  end

  validate :schema
  step :authorize, with: :'operations.authorization.update'
  step :end_date, with: :'operations.end_date'
  step :persist, with: :'operations.action.update'

  def schema
    Schemas::Transactions::Admin::BillingCycle::Update
  end

end
