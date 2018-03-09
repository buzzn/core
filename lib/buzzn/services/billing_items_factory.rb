require_relative '../builders/billing/item_builder'

class Services::BillingItemsFactory

  # This is the object structure we're returning
  # [
  #   { market_location: <MarketLocation instance 1>, items: [ Brick.new(...), ...] },
  #   { market_location: <MarketLocation instance 2>, items: [ ... ] }
  # ]
  def items_by_market_location(group:, date_range:)
    group.market_locations.consumption.map do |location|
      { market_location: location, items: items_for_market_location(location, date_range) }
    end
  end

  private

  def items_for_market_location(location, date_range)
    billed_items       = find_billed_items(location, date_range)
    unbilled_date_range = billed_items.empty? ? date_range : billed_items.last.end_date...date_range.last
    unbilled_items     = build_unbilled_items(location, unbilled_date_range)
    billed_items + unbilled_items
  end

  def find_billed_items(location, date_range)
    billings = location.billings_in_date_range(date_range)
    (billings.map(&:items).flatten || []).sort_by(&:begin_date)
  end

  # We don't handle register and tariff changes in the first billing story.
  # So we can keep it simple -- each contract will result in one item.
  def build_unbilled_items(location, date_range)
    if date_range_zero?(date_range)
      []
    else
      location.contracts_in_date_range(date_range).map { |contract| build_item(contract, date_range) }
    end
  end

  def build_item(contract, date_range)
    Builders::Billing::ItemBuilder.from_contract(contract, date_range)
  end

  # Ruby can't calculate the length (in days) of a range object when the range is defined with dates -- it always returns nil.
  # TODO: use exclude_end? to prevent one-off errors
  def date_range_zero?(date_range)
    date_range.last == date_range.first
  end

end
