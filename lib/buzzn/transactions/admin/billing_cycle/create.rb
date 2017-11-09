require_relative '../billing_cycle'
require_relative '../../../schemas/transactions/admin/billing_cycle/create'

class Transactions::Admin::BillingCycle::Create < Transactions::Base
  def self.for(localpool)
    new.with_step_args(
      validate: [Schemas::Transactions::Admin::BillingCycle::Create],
      authorize: [localpool, *localpool.permissions.billing_cycles.create],
      persist: [localpool.billing_cycles]
    )
  end

  step :validate, with: :'operations.validation'
  step :authorize, with: :'operations.authorization.generic'
  step :persist

  def persist(input, billing_cycles)
    Right(Admin::BillingCycleResource.new(billing_cycles.objects.create!(input), billing_cycles.context))
  end
end
