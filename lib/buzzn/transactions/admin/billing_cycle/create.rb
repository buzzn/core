require_relative '../billing_cycle'
require_relative '../../../schemas/transactions/admin/billing_cycle/create'

class Transactions::Admin::BillingCycle::Create < Transactions::Base

  def self.for(localpool)
    new.with_step_args(
      validate: [Schemas::Transactions::Admin::BillingCycle::Create],
      authorize: [localpool, *localpool.permissions.billing_cycles.create],
      date_range: [localpool],
      make_bars: [localpool],
      persist_billings: [],
      persist_billing_cycle: [localpool, localpool.billing_cycles]
    )
  end

  # FIXME: use an around step to wrap everythnig in a transaction http://dry-rb.org/gems/dry-transaction/around-steps/
  step :validate, with: :'operations.validation'
  step :authorize, with: :'operations.authorization.generic'
  step :end_date, with: :'operations.end_date'
  step :date_range
  step :make_bars, with: :'operations.bars'
  step :persist_billings
  step :persist_billing_cycle

  def date_range(input, localpool)
    begin_date = localpool.next_billing_cycle_begin_date
    Right(input.merge(date_range: begin_date...input[:end_date]).except(:end_date))
  end

  def persist_billings(input)
    input[:bars].each(&:save!)
    Right(input)
  end

  def persist_billing_cycle(input, localpool, billing_cycles)
    attrs = input.slice(:date_range, :name).merge(localpool: localpool.object)
    resource = Admin::BillingCycleResource.new(billing_cycles.objects.create!(attrs), billing_cycles.context)
    Right(resource)
  end

end
