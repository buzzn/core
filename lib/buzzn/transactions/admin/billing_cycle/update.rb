require_relative '../billing_cycle'
require_relative '../../../schemas/transactions/admin/billing_cycle/update'

class Transactions::Admin::BillingCycle::Update < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update'
  tee :end_date, with: :'operations.end_date'
  map :persist, with: :'operations.action.update'

  def schema
    Schemas::Transactions::Admin::BillingCycle::Update
  end

end
