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
    begin_date...params.delete(:end_date)
  end

  def create_billing_cycle(params:, resource:, date_range:)
    params[:date_range] = date_range
    params[:localpool]  = resource.object
    BillingCycle.create!(params)
  end

  def create_billings(params:, resource:, date_range:, create_billing_cycle:)
    register_metas = resource.object.register_metas_by_registers
    errors = {}
    register_metas.each do |register_meta|
      register_meta.contracts.each do |contract|
        if contract.begin_date > date_range.last || contract.is_a?(Contract::LocalpoolThirdParty)
          next
        end
        contract_billing_date_range = contract.minmax_date_range(date_range)
        attrs = {
          begin_date: contract_billing_date_range.first,
          last_date:  contract_billing_date_range.last - 1.day, # last_date!
        }
        begin
          Transactions::Admin::Billing::Create.new.(resource: resource.contracts.retrieve(contract.id).billings,
                                                    params: attrs,
                                                    contract: contract,
                                                    billing_cycle: create_billing_cycle)
        rescue Buzzn::ValidationError => e
          errors['create_billings'] = [] if errors['create_billings'].nil?
          errors['create_billings'] << {contract_id: contract.id, contract_number: contract.full_contract_number, errors: e.errors}
        end
      end
    end
    unless errors.empty?
      raise Buzzn::ValidationError.new(errors)
    end
  end

  def wrap_up(create_billing_cycle:,**)
    Admin::BillingCycleResource.new(create_billing_cycle)
  end

end
