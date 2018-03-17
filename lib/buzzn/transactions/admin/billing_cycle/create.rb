require_relative '../billing_cycle'
require_relative '../../../schemas/transactions/admin/billing_cycle/create'

class Transactions::Admin::BillingCycle::Create < Transactions::Base

  def self.for(localpool)
    new.with_step_args(
      validate: [Schemas::Transactions::Admin::BillingCycle::Create],
      authorize: [localpool, *localpool.permissions.billing_cycles.create],
      date_range: [localpool],
      build_bars: [localpool],
      create_billing_cycle: [localpool, localpool.billing_cycles],
      create_billings: []
    )
  end

  # FIXME: use an around step to wrap everything in a transaction http://dry-rb.org/gems/dry-transaction/around-steps/
  step :validate, with: :'operations.validation'
  step :authorize, with: :'operations.authorization.generic'
  step :end_date, with: :'operations.end_date'
  step :date_range
  step :build_bars, with: :'operations.bars'
  step :create_billing_cycle
  step :create_billings

  def date_range(input, localpool)
    begin_date = localpool.next_billing_cycle_begin_date
    date_range = begin_date...input.delete(:end_date)
    Right(input.merge(date_range: date_range))
  end

  def create_billing_cycle(input, localpool, billing_cycles)
    attrs = input.slice(:date_range, :name).merge(localpool: localpool.object)
    resource = Admin::BillingCycleResource.new(billing_cycles.objects.create!(attrs), billing_cycles.context)
    Right(input.merge(billing_cycle: resource))
  end

  def create_billings(input)
    input[:bars].each do |_market_location, items|
      Billing.create!(
        date_range:    input[:date_range],
        billing_cycle: input[:billing_cycle],
        items:         items # passing in unsaved BillingItem instances (built in :make_bars step)
      )
    end
    Right(input[:billing_cycle])
  end

end
