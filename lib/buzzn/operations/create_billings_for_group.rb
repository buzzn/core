require_relative '../operations'

#
# Creates new billings for a group in a given date range.
#
class Operations::CreateBillingsForGroup

  include Dry::Transaction::Operation
  include Import[factory: 'services.unbilled_billing_items_factory']

  def call(billing_cycle)
    group                 = billing_cycle.localpool
    date_range            = billing_cycle.date_range
    market_locations      = group.market_locations.consumption
    unsaved_billing_items = factory.call(market_locations: market_locations, date_range: date_range)
    billings = unsaved_billing_items.map do |market_location|
      market_location[:contracts].map do |contract|
        create_billing(contract[:contract], contract[:items], billing_cycle)
      end
    end
    billings.flatten!
    billings.all?(&:persisted?) ? Success(billing_cycle) : Failure("Failed to save all billings: #{billings.collect {|b| b.invariant.errors }.inspect}")
  end

  private

  def create_billing(contract, billing_items, billing_cycle)
    attrs = {
      status:        'open',
      billing_cycle: billing_cycle,
      contract:      contract,
      date_range:    billing_items.first.date_range.first...billing_items.last.date_range.last,
      items:         billing_items
    }
    billing = Billing.new(attrs)
    billing.save!(attrs) if billing.invariant.errors.empty?
    billing
  end

end
