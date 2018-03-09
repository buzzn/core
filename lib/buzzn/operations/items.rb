require_relative '../operations'

class Operations::Items

  include Dry::Transaction::Operation
  include Import[factory: 'services.billing_items_factory']

  def call(billing_cycle)
    cycle = billing_cycle.object
    localpool = cycle.localpool
    range = cycle.begin_date...cycle.end_date
    result = factory.items_by_market_location(group: localpool, date_range: range)
    Right(result)
  end

end