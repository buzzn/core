class Services::BillingBricksFactory

  class << self

    # This is the object structure we're returning
    # [
    #   { name: 'Market location 1', bricks: [ Brick.new(...), ...] },
    #   { name: 'Market location 2', bricks: [ ... ] }
    # ]
    def bricks_by_market_location(group:, date_range:)
      market_locations(group).map { |location| { name: location.name, bricks: bricks_for_market_location(location, date_range) } }
    end

    private

    # TODO: use group.market_locations.consumption which is still on the branch create-billings-on-import
    # TODO: discuss moving the consumption/production info to the market location.
    # Then we could easily make a MarketLocation.consumption scope and use that here.
    def market_locations(group)
      group.market_locations.order(:name).to_a.select(&:consumption?)
    end

    # We don't handle register and tariff changes in the first billing story.
    # So we can keep it simple -- each contract will result in one brick.
    def bricks_for_market_location(location, date_range)
      contracts_for_market_location(location, date_range).map { |contract| new_brick(contract, date_range) }
    end

    def contracts_for_market_location(location, date_range)
      location.contracts_for_range(date_range)
    end

    def new_brick(contract, date_range)
      # TODO: adapt method to work with a date_range as well
      BillingBrick.from_contract(contract, date_range.first, date_range.last)
    end

  end

end
