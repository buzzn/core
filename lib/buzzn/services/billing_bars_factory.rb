require_relative '../builders/billing/item_builder'

class Services::BillingBarsFactory

  # This is the object structure we're returning
  # [
  #   { market_location: <MarketLocation instance 1>, items: [ Item.new(...), ...] },
  #   { market_location: <MarketLocation instance 2>, items: [ ... ] }
  # ]
  def bars_by_market_location(group:, date_range:)
    group.market_locations.consumption.map do |location|
      { market_location: location, bars: bars_for_market_location(location, date_range) }
    end
  end

  private

  def bars_for_market_location(location, date_range)
    billed_bars = find_billed_bars(location, date_range)
    unbilled_date_range = billed_bars.empty? ? date_range : billed_bars.last.end_date...date_range.last
    unbilled_bars = create_unbilled_bars(location, unbilled_date_range)
    billed_bars + unbilled_bars
  end

  def find_billed_bars(location, date_range)
    billings = location.billings_in_date_range(date_range)
    (billings.map(&:items).flatten || []).sort_by(&:begin_date)
  end

  # We don't handle register and tariff changes in the first billing story.
  # So we can keep it simple -- each contract will result in one bar.
  def create_unbilled_bars(location, date_range)
    if date_range_zero?(date_range)
      []
    else
      location.contracts_in_date_range(date_range).map { |contract| build_bar(contract, date_range) }
    end
  end

  def build_bar(contract, date_range)
    Builders::Billing::ItemBuilder.from_contract(contract, date_range)
  end

  # Ruby can't calculate the length (in days) of a range object when the range is defined with dates -- it always returns nil.
  # TODO: use exclude_end? to prevent one-off errors
  def date_range_zero?(date_range)
    date_range.last == date_range.first
  end

end
