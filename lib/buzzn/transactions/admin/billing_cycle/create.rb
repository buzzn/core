require_relative '../billing_cycle'
require_relative '../../../schemas/transactions/admin/billing_cycle/create'

class Transactions::Admin::BillingCycle::Create < Transactions::Base

  def self.for(localpool)
    new.with_step_args(
      validate: [Schemas::Transactions::Admin::BillingCycle::Create],
      authorize: [localpool, *localpool.permissions.billing_cycles.create],
      set_date_range: [localpool],
      create_readings: [localpool],
      build_bars: [localpool],
      create_billing_cycle: [localpool, localpool.billing_cycles],
      create_billings: []
    )
  end

  step :validate, with: :'operations.validation'
  step :authorize, with: :'operations.authorization.generic'
  step :end_date, with: :'operations.end_date'
  step :set_date_range

  # TODO
  # around :do_persist
  step :create_readings, with: :'operations.create_readings_for_group'
  # TODO: create billing items
  # TODO: create billings
  step :build_bars, with: :'operations.bars'
  # TODO: create billing cycle
  step :create_billing_cycle
  step :create_billings # use a billing builder; will get the readings

  def set_date_range(input, localpool)
    begin_date = localpool.next_billing_cycle_begin_date
    date_range = begin_date...input.delete(:end_date)
    Right(input.merge(date_range: date_range))
  end

  # I'm not convinced passing a big input hash from one operation to the other is a good idea:
  # 1) It's not clear which hash entries are actually relevant, and
  # 2) strongly couples the operations through the hash key names.
  # So I'm wrapping the operation to decouple the arguments.
  def create_readings(input, localpool)
    super(group: localpool, date_time: input[:date_range].last.at_beginning_of_day)
  end

  def create_billing_cycle(input, localpool, billing_cycles)
    attrs = input.slice(:date_range, :name).merge(localpool: localpool.object)
    resource = Admin::BillingCycleResource.new(billing_cycles.objects.create!(attrs), billing_cycles.context)
    Right(input.merge(billing_cycle: resource))
  end

  # TODO:
  # - validate stuff
  # - don't create billings for bars that are already closed. Yes, we get them here because operations.bars still
  #   returns the already saved billings as well.
  # - handle errors with Left(), not with exceptions
  # - make status of billing open per default, without having to assign it on creation
  # - don't pass through contract on the billing item
  def create_billings(input)
    input[:bars].each do |row|
      row[:bars].each do |bar|
        Billing.create!(
          status:        'open',
          billing_cycle: input[:billing_cycle].object,
          contract:      bar.contract,
          date_range:    bar.date_range,
          items:         [bar]
        )
      end
    end
    Right(input[:billing_cycle])
  end

end
