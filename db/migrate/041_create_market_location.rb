require 'buzzn/schemas/constraints/register/market_location'

class CreateMarketLocation < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::Register::MarketLocation)

  def up
    SCHEMA.up(:market_locations2, self)

    add_belongs_to :register_meta, :market_locations2, index: true, null: true

    add_foreign_key :register_meta, :market_locations2, name: :fk_register_meta_market_location

    add_index :market_locations2, :market_location_id, unique: true
  end

  def down
    SCHEMA.down(:market_locations2, self)
  end

end
