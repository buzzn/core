require_relative '../billing'
require_relative '../../../schemas/transactions/admin/billing/update'

class Transactions::Admin::Billing::Update < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update'
  map :persist, with: :'operations.action.update'

  def schema
    Schemas::Transactions::Admin::Billing::Update
  end

end
