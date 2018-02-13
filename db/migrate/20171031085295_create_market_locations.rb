require 'buzzn/schemas/constraints/market_location'

class CreateMarketLocations < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::MarketLocation)

  def up
    SCHEMA.up(:market_locations, self)

    add_foreign_key :market_locations, :groups
    # add_foreign_key :market_locations, :contracts

    add_index :market_locations, :market_location_id, unique: true
    add_index :market_locations, :group_id
  end

  def down
    SCHEMA.down(:market_locations, self)
  end

end
