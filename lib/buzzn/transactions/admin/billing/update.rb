require_relative '../billing'
require_relative '../../../schemas/transactions/admin/billing/update'

class Transactions::Admin::Billing::Update < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update_ng'
  step :persist, with: :'operations.action.update_ng'

  def schema
    Schemas::Transactions::Admin::Billing::Update
  end

end
