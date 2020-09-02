require_relative '../billing'
require_relative '../../../schemas/transactions/admin/billing/create'

class Transactions::Admin::Billing::Create < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.create'
  tee :validate_contract
  tee :validate_dates
  tee :set_end_date, with: :'operations.end_date'
  add :date_range
  tee :validate_registers
  tee :complete_params
  around :db_transaction
  add :billing_item
  map :create_billing, with: :'operations.action.create_item'

  def schema
    Schemas::Transactions::Admin::Billing::Create
  end

  def validate_contract(contract:, **)
    unless contract.is_a? Contract::LocalpoolPowerTaker
      raise Buzzn::ValidationError.new({contract: ['not a valid contract']}, contract)
    end
    # validate
    subject = Schemas::Support::ActiveRecordValidator.new(contract)
    result = Schemas::PreConditions::Contract::CreateBilling.call(subject)
    unless result.success?
      raise Buzzn::ValidationError.new(result.errors, contract)
    end
  end

  def validate_dates(params:, contract:, **)
    if params[:last_date] < params[:begin_date]
      raise Buzzn::ValidationError.new({last_date: ['must be after begin date']}, contract)
    end
    if params[:begin_date] < contract.begin_date
      raise Buzzn::ValidationError.new({begin_date: ["must be after contract[\"begin_date\"]"]}, contract)
    end
    if contract.tariffs.at(params[:begin_date]).empty?
      raise Buzzn::ValidationError.new({contract: ['tariffs must cover begin date']}, contract)
    end
  end

  def date_range(params:, contract:, **)
    contract.minmax_date_range(params[:begin_date]...params[:end_date])
  end

  def validate_registers(params:, contract:, date_range:, **)
    if contract.register_meta.registers.to_a.keep_if { |register| register.installed_at.date < date_range.last && (register.decomissioned_at.nil? || register.decomissioned_at.date > date_range.first) }.empty?
      raise Buzzn::ValidationError.new({register_meta: ['no register installed in date range']}, contract)
    end
  end

  def complete_params(params:, billing_cycle:, **)
    params[:billing_cycle] = billing_cycle
    params[:status] = :open
  end

  def billing_item(params:, contract:, resource:, date_range:, **)
    billing_data = Service::BillingData.data(contract, begin_date: date_range.first, end_date: date_range.last)
    
    billing_data[:items].each do |item|
      errors = item.invariant.errors.except(:billing, :contract)
      unless errors.empty?
        raise Buzzn::ValidationError.new(errors)
      end
    end

    params[:items] = billing_data[:items]
    params[:begin_date] = billing_data[:begin_date]
    params[:end_date] = billing_data[:end_date]
  end

  def create_billing(params:, resource:, **)
    Admin::BillingResource.new(
      *super(resource, params)
    )
  end

end
