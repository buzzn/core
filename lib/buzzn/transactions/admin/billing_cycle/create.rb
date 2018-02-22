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

  step :validate, with: :'operations.validation'
  step :authorize, with: :'operations.authorization.generic'
  step :begin_date
  step :persist

  def begin_date(input, localpool)
    input[:begin_date] =
      if localpool.billing_cycles.objects.empty?
        localpool.start_date
      else
        localpool.billing_cycles.objects.order(:begin_date).last.end_date
      end
    Right(input)
  end

  def persist(input, billing_cycles)
    do_persist do
      Admin::BillingCycleResource.new(billing_cycles.objects.create!(input), billing_cycles.context)
    end
  end

end
