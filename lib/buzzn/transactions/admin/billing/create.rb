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
    begin
      in_range_tariffs = parent.contexted_tariffs.keep_if do |tariff|
        if tariff.end_date.nil?
          tariff.begin_date <= date_range.last
        else
          tariff.begin_date <= date_range.last && tariff.end_date >= date_range.first
        end
      end
      ranges = []
      # calculate new range for each tariff
      new_max = date_range.first
      in_range_tariffs.each do |tariff|
        range = {}
        range[:begin_date] = [tariff.begin_date, new_max].max
        range[:end_date]   = [tariff.end_date || date_range.last, date_range.last].min
        range[:tariff]     = tariff.tariff
        ranges << range
      end
      # split even further, split with already existing BillingItems
      existing_billing_items = parent.register_meta.register.billing_items.in_date_range(date_range)
      existing_billing_items.each do |item|
        # search correct range
        ranges.each_with_index do |range, idx|
          if range[:begin_date] <= item.begin_date && range[:end_date] <= item.end_date
            ranges[idx][:end_date] = item.begin_date
            params[:end_date]      = [item.begin_date, params[:end_date]].min
          end
          if range[:begin_date] <= item.begin_date && range[:end_date] > item.end_date
            new_range = range.dup
            new_range[:begin_date] = item.end_date
            ranges[idx][:end_date] = item.begin_date
            ranges << new_range
          end
          if range[:begin_date] > item.begin_date && range[:begin_date] < item.end_date
            # update also params[:begin] here to line up
            params[:begin_date]      = [item.end_date, params[:begin_date]].max
            ranges[idx][:begin_date] = item.end_date
          end
        end

      end

      items = []
      ranges.each do |range|
        items << Builders::Billing::ItemBuilder.from_contract(parent, range[:begin_date]..range[:end_date], range[:tariff])
      end
    rescue Buzzn::DataSourceError => error
      raise Buzzn::ValidationError.new(error.message)
    end
    items.each do |item|
      errors = item.invariant.errors.except(:billing, :contract)
      unless errors.empty?
        raise Buzzn::ValidationError.new(:items => errors)
      end
    end
    params[:items] = items
  end

  def create_billing(params:, resource:, **)
    Admin::BillingResource.new(
      *super(resource, params)
    )
  end

end
