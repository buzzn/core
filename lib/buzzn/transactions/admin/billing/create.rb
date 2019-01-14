require_relative '../billing'
require_relative '../../../schemas/transactions/admin/billing/create'

class Transactions::Admin::Billing::Create < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.create'
  tee :validate_parent
  tee :validate_dates
  tee :set_end_date, with: :'operations.end_date'
  add :date_range
  tee :complete_params
  around :db_transaction
  add :billing_item
  map :create_billing, with: :'operations.action.create_item'

  def schema
    Schemas::Transactions::Admin::Billing::Create
  end

  def validate_parent(parent:, **)
    unless parent.is_a? Contract::LocalpoolPowerTaker
      raise Buzzn::ValidationError.new('not a valid parent')
    end
    # validate
    subject = Schemas::Support::ActiveRecordValidator.new(parent)
    result = Schemas::PreConditions::Contract::CreateBilling.call(subject)
    unless result.success?
      raise Buzzn::ValidationError.new(result.errors)
    end
  end

  def validate_dates(params:, parent:, **)
    if params[:last_date] < params[:begin_date]
      raise Buzzn::ValidationError.new(:last_date => ['must be after begin_date'])
    end
    if params[:begin_date] < parent.begin_date
      raise Buzzn::ValidationError.new(:begin_date => ['must be after contract[\'begin_date\']'])
    end
  end

  def date_range(params:, parent:, **)
    contract = parent
    date_range = params[:begin_date]...params[:end_date]

    if contract.end_date && contract.end_date < date_range.last
      date_range = date_range.first...contract.end_date
    end
    if contract.begin_date > date_range.first
      date_range = contract.begin_date...date_range.last
    end
    params[:begin_date] = date_range.first
    params[:end_date]   = date_range.last
    date_range
  end

  def complete_params(params:, **)
    params[:status] = :open
  end

  def billing_item(params:, parent:, resource:, date_range:, **)

    billing_data = Service::BillingData.data(parent, begin_date: date_range.first, end_date: date_range.last)

    billing_data[:items].each do |item|
      errors = item.invariant.errors.except(:billing, :contract)
      unless errors.empty?
        raise Buzzn::ValidationError.new(:items => errors)
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
