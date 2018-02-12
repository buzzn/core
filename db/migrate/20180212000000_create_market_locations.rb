require 'buzzn/schemas/constraints/market_location'

class CreateMarketLocations < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::MarketLocation)

  def up
    SCHEMA.up(:market_locations, self)

    # add_foreign_key :market_locations, :contracts, name: :fk_market_locations_contracts, column: :localpool_power_taker_contract_id
    add_index :market_locations, :market_location_id, unique: true
  end

  def down
    SCHEMA.down(:market_locations, self)
  end

end
