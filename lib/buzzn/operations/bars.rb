require_relative '../operations'

class Operations::Bars

  include Dry::Transaction::Operation
  include Import[factory: 'services.billing_bars_factory']

  def call(billing_cycle)
    cycle = billing_cycle.object
    localpool = cycle.localpool
    range = cycle.begin_date...cycle.end_date
    result = factory.bars_by_market_location(group: localpool, date_range: range)
    Success(result)
  end

end
