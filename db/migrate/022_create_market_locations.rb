require 'buzzn/schemas/constraints/market_location'

class CreateMarketLocations < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::MarketLocation)

  def up
    SCHEMA.up(:market_locations, self)

    add_belongs_to :registers, :market_location, index: true, null: true

    add_foreign_key :registers, :market_locations, name: :fk_registers_market_location
  end

  def down
    SCHEMA.down(:market_locations, self)
  end

end
