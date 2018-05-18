require_relative '../billing_cycle'
require_relative '../../../schemas/transactions/admin/billing_cycle/create'

class Transactions::Admin::BillingCycle::Create < Transactions::Base

  validate :schema
  authorize :allowed_roles
  tee :end_date, with: :'operations.end_date'
  tee :set_date_range
  map :create_billing_cycle, with: :'operations.action.create_item'

  def schema
    Schemas::Transactions::Admin::BillingCycle::Create
  end

  def allowed_roles(permission_context:)
    permission_context.billing_cycles.create
  end

  def set_date_range(params:, resource:)
    begin_date = resource.next_billing_cycle_begin_date
    date_range = begin_date...params.delete(:end_date)
    params.merge!(date_range: date_range)
  end

  def create_billing_cycle(params:, resource:)
    attrs = params.slice(:date_range, :name)
    Admin::BillingCycleResource.new(
      *super(resource.billing_cycles, attrs)
    )
  end

end
