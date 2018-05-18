require_relative '../billing_cycle'
require_relative '../../../schemas/transactions/admin/billing_cycle/create'

class Transactions::Admin::BillingCycle::Create < Transactions::Base

  def self.for(group_resource)
    group_model = group_resource.object
    new.with_step_args(
      authorize: [group_resource, *group_resource.permissions.billing_cycles.create],
      set_date_range: [group_resource],
      create_billing_cycle: [group_model]
    )
  end

  validate :schema
  step :authorize, with: :'operations.authorization.generic'
  tee :end_date
  tee :set_date_range
  around :db_transaction
  map :create_billing_cycle
  map :build_response

  def end_date(input)
    input[:end_date] = input.delete(:last_date) + 1.day if input.key?(:last_date)
  end

  def schema
    Schemas::Transactions::Admin::BillingCycle::Create
  end

  def set_date_range(input, group)
    begin_date = group.next_billing_cycle_begin_date
    date_range = begin_date...input.delete(:end_date)
    input.merge!(date_range: date_range)
  end

  def create_billing_cycle(input, group)
    attrs = input.slice(:date_range, :name).merge(localpool: group)
    BillingCycle.create!(attrs)
  end

  def build_response(billing_cycle)
    Admin::BillingCycleResource.new(billing_cycle)
  end

end
