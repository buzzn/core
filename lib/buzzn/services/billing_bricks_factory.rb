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
    market_locations.map { |location| { name: location.name, bricks: bricks_for_location(location) } }
  end

  private

  # TODO: discuss moving the consumption/production info to the market location
  def market_locations
    group.market_locations.order(:name).to_a.select(&:consumption?)
  end

  # A brick is defined by having the same tariff, contract and register.
  # As soon as one of those changes, we make a new brick.
  def bricks_for_location(location)
    contracts_for_location(location).map { |contract| new_brick(contract) }
    # [BillingBrick.new(begin_date: begin_date, end_date: end_date, market_location: location, type: :power_taker)]
  end

  def contracts_for_location(location)
    location.billable_contracts_for_period(begin_date, end_date)
  end

  def new_brick(contract)
    BillingBrick.from_contract(contract, begin_date, end_date)
  end

end