require_relative '../billing'
require_relative '../../../schemas/transactions/admin/billing/create_regular'

class Transactions::Admin::Billing::CreateRegular < Transactions::Base
  def self.for(billing_cycle)
    new.with_step_args(
      validate: [Schemas::Transactions::Admin::Billing::CreateRegular],
      authorize: [billing_cycle, *billing_cycle.permissions.billings.create],
      persist: [billing_cycle]
    )
  end

  step :validate, with: :'operations.validation'
  step :authorize, with: :'operations.authorization.generic'
  step :persist

  def persist(input, billing_cycle)
    # FIXME create_regular_billing on model is not the right place for such invasiv business
    result = billing_cycle.object.create_regular_billings(input[:account_year])
    Right(billing_cycle.all(billing_cycle.permissions.billings, result, Admin::BillingResource))
  end
end
