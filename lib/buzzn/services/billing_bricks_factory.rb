class Services::BillingBricksFactory

  extend Dry::Initializer
  option :begin_date
  option :end_date
  option :group

  # This is the object structure we're returning
  # [
  #   { name: 'Market location 1', bricks: [ Brick.new(...), ...] },
  #   { name: 'Market location 2', bricks: [ ... ] }
  # ]
  def bricks_by_market_location
    market_locations.map { |location| { name: location.name, bricks: bricks_for_market_location(location) } }
  end

  private

  # TODO: use group.market_locations.consumption which is still on the branch create-billings-on-import
  # TODO: discuss moving the consumption/production info to the market location.
  # Then we could easily make a MarketLocation.consumption scope and use that here.
  def market_locations
    group.market_locations.order(:name).to_a.select(&:consumption?)
  end

  # We don't handle register and tariff changes in the first billing story.
  # So we can keep it simple -- each contract will result in one brick.
  def bricks_for_market_location(location)
    contracts_for_market_location(location).map { |contract| new_brick(contract) }
  end

  def contracts_for_market_location(location)
    location.contracts_for_range(begin_date..end_date)
  end

  def new_brick(contract)
    BillingBrick.from_contract(contract, begin_date, end_date)
  end

end
