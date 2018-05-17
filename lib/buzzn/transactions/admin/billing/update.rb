require_relative '../billing'
require_relative '../../../schemas/transactions/admin/billing/update'

class Transactions::Admin::Billing::Update < Transactions::Base

  def self.for(billing)
    super(billing, :authorize, :persist)
  end

  validate :schema
  step :authorize, with: :'operations.authorization.update'
  step :persist, with: :'operations.action.update'

  def schema
    Schemas::Transactions::Admin::Billing::Update
  end

end
