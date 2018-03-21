require_relative '../billing_cycle'
require_relative '../../../schemas/transactions/admin/billing_cycle/create'

class Transactions::Admin::BillingCycle::Create < Transactions::Base

  def self.for(group_resource)
    group_model = group_resource.object
    new.with_step_args(
      validate: [Schemas::Transactions::Admin::BillingCycle::Create],
      authorize: [group_resource, *group_resource.permissions.billing_cycles.create],
      set_date_range: [group_resource],
      create_readings: [group_model],
      create_billing_cycle: [group_model, group_resource.billing_cycles]
    )
  end

  around :db_transaction
  step :validate, with: :'operations.validation'
  step :authorize, with: :'operations.authorization.generic'
  step :end_date, with: :'operations.end_date'
  step :set_date_range
  step :create_readings, with: :'operations.create_readings_for_group'
  step :create_billing_cycle
  step :create_billings, with: :'operations.create_billings_for_group'

  def set_date_range(input, group)
    begin_date = group.next_billing_cycle_begin_date
    date_range = begin_date...input.delete(:end_date)
    Success(input.merge(date_range: date_range))
  end

  # I'm not convinced passing a big input hash from one operation to other is a good idea:
  # 1) It's not clear which hash entries are actually relevant, and
  # 2) strongly couples the operations through the hash key names.
  # So I'm wrapping the operation to decouple the arguments.
  def create_readings(input, group)
    super(group: group, date_time: input[:date_range].last.at_beginning_of_day)
    Success(input)
  end

  def create_billing_cycle(input, group, billing_cycles)
    attrs = input.slice(:date_range, :name).merge(localpool: group)
    resource = Admin::BillingCycleResource.new(billing_cycles.objects.create!(attrs), billing_cycles.context)
    Success(resource.object)
  end

end
