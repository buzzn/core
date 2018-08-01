require 'buzzn/schemas/constraints/meter/metering_location'

class CreateMeteringLocations < ActiveRecord::Migration

  SCHEMA = Schemas::Support::MigrationVisitor.new(Schemas::Constraints::Meter::MeteringLocation)

  def up
    SCHEMA.up(:metering_locations, self)

    add_belongs_to :meters, :metering_location, index: true, null: true

    add_foreign_key :meters, :metering_locations, name: :fk_meter_metering_location

    add_index :metering_locations, :metering_location_id, unique: true
  end

  def down
    SCHEMA.down(:metering_locations, self)
  end

end
