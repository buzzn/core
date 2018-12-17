require_relative '../billing'
require_relative '../../../schemas/transactions/admin/billing/create'

class Transactions::Admin::Billing::Create < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.create'
  tee :validate_parent
  tee :validate_end_date
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
  end

  def validate_end_date(params:, **)
    if params[:end_date] < params[:begin_date]
      raise Buzzn::ValidationError.new(:end_date => ['must be after begin_date'])
    end
  end

  def date_range(params:, parent:, **)
    contract = parent
    register_meta = contract.register_meta
    date_range = params[:begin_date]...params[:end_date]

    last_billing = register_meta.billings_in_date_range(date_range).order(:end_date).last
    date_range = last_billing ? last_billing.end_date...date_range.last : date_range

    # now shrink date range to contract
    if contract.end_date && contract.end_date < date_range.last
      date_range = date_range.first...contract.end_date
    end
    date_range
  end

  def complete_params(params:, **)
    params[:status] = :open
  end

  def billing_item(params:, parent:, resource:, date_range:, **)
    params[:items] = [Builders::Billing::ItemBuilder.from_contract(parent, date_range)]
  end

  def create_billing(params:, resource:, **)
    Admin::BillingResource.new(
      *super(resource, params)
    )
  end

end
