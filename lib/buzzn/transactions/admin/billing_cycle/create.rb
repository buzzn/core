require_relative '../billing_cycle'
require_relative '../../../schemas/transactions/admin/billing_cycle/create'

class Transactions::Admin::BillingCycle::Create < Transactions::Base

  def self.for(localpool)
    new.with_step_args(
      validate: [Schemas::Transactions::Admin::BillingCycle::Create],
      authorize: [localpool, *localpool.permissions.billing_cycles.create],
      date_range: [localpool],
      make_bars: [localpool],
      persist: [localpool, localpool.billing_cycles]
    )
  end

  step :validate, with: :'operations.validation'
  step :authorize, with: :'operations.authorization.generic'
  step :end_date, with: :'operations.end_date'
  step :date_range
  step :make_bars, with: :'operations.bars'
  step :persist

  def date_range(input, localpool)
    begin_date = localpool.next_billing_cycle_begin_date
    Right(input.merge(date_range: begin_date...input[:end_date]).except(:end_date))
  end

  def persist(input, localpool, billing_cycles)
    do_persist do
      persist_bars(input[:bars], localpool)
      billing_cycle_attrs = input.slice(:date_range, :name).merge(localpool: localpool.object)
      Admin::BillingCycleResource.new(billing_cycles.objects.create!(billing_cycle_attrs), billing_cycles.context)
    end
  end

  private

  def persist_bars(bars, localpool)
  end

end
