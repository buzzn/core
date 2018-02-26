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
    market_locations.map do |location|
      { name: location.name, bricks: bricks_for_location(location) }
    end
  end

  private

  # TODO: discuss moving the consumption/production info to the market location
  def market_locations
    group.market_locations.order(:name).to_a.select(&:consumption?)
  end

  # a brick is defined by having the same tariff, contract and register.
  # As soon as one of those changes in the date range we're looking at, we need to generate a new brick.
  def bricks_for_location(location)
    [BillingBrick.new(start_date: start_date, end_date: end_date, market_location: location, type: :powertaker)]
  end

end
