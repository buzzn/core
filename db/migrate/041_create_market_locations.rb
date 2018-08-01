require 'buzzn/schemas/constraints/register/market_location'

class CreateMarketLocations < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::Register::MarketLocation)

  def up
    SCHEMA.up(:market_locations, self)

    add_belongs_to :register_meta, :market_location, index: true, null: true

    add_foreign_key :register_meta, :market_locations, name: :fk_register_meta_market_location

    add_index :market_locations, :market_location_id, unique: true
  end

  def down
    SCHEMA.down(:market_locations, self)
  end

end
