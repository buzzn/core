require_relative '../billing_cycle'
require_relative '../../../schemas/transactions/admin/billing_cycle/update'

class Transactions::Admin::BillingCycle::Update < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update_ng'
  tee :end_date, with: :'operations.end_date_ng'
  step :persist, with: :'operations.action.update_ng'

  def schema
    Schemas::Transactions::Admin::BillingCycle::Update
  end

end
