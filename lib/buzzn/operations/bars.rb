require_relative '../operations'

class Operations::Bars

  include Dry::Transaction::Operation
  include Import[factory: 'services.billing_bars_factory']

  def call(input, localpool)
    bars = factory.bars_by_market_location(group: localpool.object, date_range: input[:date_range])
    Right(input.merge(bars: bars))
  end

end
