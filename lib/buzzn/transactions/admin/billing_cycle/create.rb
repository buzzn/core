require_relative '../billing_cycle'
require_relative '../../../schemas/transactions/admin/billing_cycle/create'

class Transactions::Admin::BillingCycle::Create < Transactions::Base

  validate :schema
  authorize :allowed_roles
  precondition :localpool_schema
  tee :localpool_schema
  tee :end_date, with: :'operations.end_date'
  add :date_range
  around :db_transaction
  add :create_billing_cycle
  tee :create_billings
  map :wrap_up

  def schema
    Schemas::Transactions::Admin::BillingCycle::Create
  end

  def localpool_schema
    Schemas::PreConditions::Localpool::CreateBillingCycle
  end

  def allowed_roles(permission_context:)
    permission_context.billing_cycles.create
  end

  def date_range(params:, resource:)
    begin_date = resource.next_billing_cycle_begin_date
    date_range = begin_date...params.delete(:end_date)
  end

  def create_billing_cycle(params:, resource:, date_range:)
    params[:date_range] = date_range
    params[:localpool]  = resource.object
    BillingCycle.create!(params)
  end

  def create_billings(params:, resource:, date_range:, create_billing_cycle:)
    register_metas = resource.object.register_metas_by_registers

    register_metas.each do |register_meta|
      register_meta.contracts.each do |contract|
        contract_billing_date_range = contract.minmax_date_range(date_range)
        billing_data = Service::BillingData.data(contract,
                                                 begin_date: contract_billing_date_range.first,
                                                 end_date: contract_billing_date_range.last)
        attrs = {}
        attrs[:items]         = billing_data[:items]
        attrs[:begin_date]    = billing_data[:begin_date]
        attrs[:end_date]      = billing_data[:end_date]
        attrs[:status]         = :open
        attrs[:billing_cycle] = create_billing_cycle
        contract.billings.create!(attrs)
      end
    end
  end

  def wrap_up(create_billing_cycle:,**)
    Admin::BillingCycleResource.new(create_billing_cycle)
  end

end
