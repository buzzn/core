require_relative '../builders/billing/brick_builder'

class Services::BillingBricksFactory

  # This is the object structure we're returning
  # [
  #   { market_location: <MarketLocation instance 1>, bricks: [ Brick.new(...), ...] },
  #   { market_location: <MarketLocation instance 2>, bricks: [ ... ] }
  # ]
  def bricks_by_market_location(group:, date_range:)
    group.market_locations.consumption.map do |location|
      { market_location: location, bricks: bricks_for_market_location(location, date_range) }
    end
  end

  private

  def bricks_for_market_location(location, date_range)
    billed_bricks       = find_billed_bricks(location, date_range)
    unbilled_date_range = billed_bricks.empty? ? date_range : billed_bricks.last.end_date..date_range.last
    unbilled_bricks     = build_unbilled_bricks(location, unbilled_date_range)
    billed_bricks + unbilled_bricks
  end

  def find_billed_bricks(location, date_range)
    billings = location.billings_in_date_range(date_range)
    (billings.map(&:bricks).flatten || []).sort_by(&:begin_date)
  end

  # We don't handle register and tariff changes in the first billing story.
  # So we can keep it simple -- each contract will result in one brick.
  def build_unbilled_bricks(location, date_range)
    location.contracts_in_date_range(date_range).map { |contract| build_brick(contract, date_range) }
  end

  def build_brick(contract, date_range)
    Billing::BrickBuilder.from_contract(contract, date_range)
  end

end
