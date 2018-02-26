class Services::BillingBricksFactory

  extend Dry::Initializer
  option :start_date
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

  def bricks_for_location(location)
    [BillingBrick.new]
  end

end
