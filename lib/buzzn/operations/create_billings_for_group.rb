require_relative '../operations'

#
# Creates new billings for a group in a given date range.
#
class Operations::CreateBillingsForGroup

  include Dry::Transaction::Operation
  include Import[factory: 'services.unbilled_billing_items_factory']

  def call(input, group)
    market_locations      = group.market_locations.consumption
    unsaved_billing_items = factory.call(market_locations: market_locations, date_range: input[:date_range])
    billings = unsaved_billing_items.map do |market_location|
      market_location[:contracts].map do |contract|
        create_billing(contract[:contract], contract[:items], input[:billing_cycle].object)
      end
    end
    billings.flatten!
    billings.all?(&:persisted?) ? Right(billings) : Left('Failed to save all billings')
  end

  private

  # TODO: validate attributes before saving
  def create_billing(contract, billing_items, billing_cycle)
    Billing.create!(
      status:        'open',
      billing_cycle: billing_cycle,
      contract:      contract,
      date_range:    billing_items.first.date_range.first...billing_items.last.date_range.last,
      items:         billing_items
    )
  end

end
