require_relative '../billing'
require_relative '../../../schemas/transactions/admin/billing/update'

class Transactions::Admin::Billing::Update < Transactions::Base
  def self.for(billing)
    super(Schemas::Transactions::Admin::Billing::Update, billing, :authorize, :persist)
  end

  step :validate, with: :'operations.validation'
  step :authorize, with: :'operations.authorization.update'
  step :persist, with: :'operations.action.update'
end
