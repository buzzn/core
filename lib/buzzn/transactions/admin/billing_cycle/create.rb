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

  def date_range(params:, resource:, vats:)
    begin_date = resource.next_billing_cycle_begin_date
    begin_date...params.delete(:end_date)
  end

  def create_billing_cycle(params:, resource:, date_range:, vats:)
    params[:date_range] = date_range
    params[:localpool]  = resource.object
    BillingCycle.create!(params)
  end

  def create_billings(params:, resource:, date_range:, create_billing_cycle:, vats:)
    register_metas = resource.object.register_metas_by_registers.uniq # uniq is critically important here!
    errors = {}
    register_metas.
    flat_map(&:contracts). # Take all groups contracts
    reject{|c| c.is_a?(Contract::LocalpoolThirdParty)}. # No Third party contracts
    reject{|contract|
      contract.begin_date >= date_range.last || # Skip those, which begin after the requested period
      (!contract.end_date.nil? &&               # Skip if there is an end date
        contract.end_date <= date_range.first)  # and it is before our period
    }.each do |contract|
        contract_billing_date_range = contract.minmax_date_range(date_range)
        attrs = {
          begin_date: contract_billing_date_range.first,
          last_date:  contract_billing_date_range.last - 1.day, # last_date!
        }

        if ((!contract.active?) && !contract.is_a?(Contract::LocalpoolGap))
          next
        end
        begin
        Transactions::Admin::Billing::Create.new.(resource: resource.contracts.retrieve(contract.id).billings,
                                                  params: attrs,
                                                  contract: contract,
                                                  billing_cycle: create_billing_cycle,
                                                  vats: vats)
        rescue Buzzn::ValidationError => e
          unless e.errors == {:register_meta => ['no register installed in date range'] }
            errors['create_billings'] = [] if errors['create_billings'].nil?
            errors['create_billings'] << {contract_id: contract.id, contract_number: contract.full_contract_number, errors: e.errors}
          end
        end
      end
    unless errors.empty?
      raise Buzzn::ValidationError.new(errors, resource.object)
    end
  end

  def wrap_up(create_billing_cycle:,**)
    Admin::BillingCycleResource.new(create_billing_cycle)
  end

end
