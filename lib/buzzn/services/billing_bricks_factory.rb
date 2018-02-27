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

  # TODO: move this to a BrickFactory or the brick itself
  def new_brick(contract)
    BillingBrick.new(
      type:            brick_type(contract),
      begin_date:      brick_begin_date(contract),
      end_date:        brick_end_date(contract),
      market_location: contract.market_location
    )
  end

  # TODO: consider moving the type code into the brick; pass in contract instead.
  # Example: Contract::LocalpoolPowerTaker => 'power_taker'
  def brick_type(contract)
    contract.model_name.name.sub('Contract::Localpool', '').underscore.to_sym
  end

  def brick_begin_date(contract)
    if contract.begin_date < begin_date
      begin_date
    else
      contract.begin_date
    end
  end

  def brick_end_date(contract)
    contract.end_date || end_date
  end

end
