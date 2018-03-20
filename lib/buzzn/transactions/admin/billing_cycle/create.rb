require_relative '../billing_cycle'
require_relative '../../../schemas/transactions/admin/billing_cycle/create'

class Transactions::Admin::BillingCycle::Create < Transactions::Base

  def self.for(localpool)
    new.with_step_args(
      validate: [Schemas::Transactions::Admin::BillingCycle::Create],
      authorize: [localpool, *localpool.permissions.billing_cycles.create],
      begin_date: [localpool],
      persist: [localpool.billing_cycles]
    )
  end

  around :db_transaction
  step :validate, with: :'operations.validation'
  step :authorize, with: :'operations.authorization.generic'
  step :begin_date
  step :end_date, with: :'operations.end_date'
  step :persist

  def begin_date(input, localpool)
    input[:begin_date] = localpool.next_billing_cycle_begin_date
    Success(input)
  end

  def persist(input, billing_cycles)
    Success(Admin::BillingCycleResource.new(billing_cycles.objects.create!(input), billing_cycles.context))
  end

end
