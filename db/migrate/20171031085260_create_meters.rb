require 'buzzn/schemas/constraints/meter/base'

class CreateMeters < ActiveRecord::Migration
  SCHEMA = Buzzn::Schemas::MigrationVisitor.new(Schemas::Constraints::Meter::Base)

  def up
    SCHEMA.up(:meters, self)

    add_column :meters, :type, :string, null: false
    add_column :meters, :sequence_number, :integer, null: true

    add_belongs_to :meters, :group, type: :uuid, index: true, null: true
    add_belongs_to :meters, :address, index: true, type: :uuid, null: true

    add_foreign_key :meters, :groups, name: :fk_meters_group
    add_foreign_key :meters, :addresses, name: :fk_meters_address

    add_index :meters, [:group_id, :sequence_number], unique: true
  end

  def down
    drop_belongs_to :meters, :group, type: :uuid, index: true, null: true
    drop_belongs_to :meters, :address, index: true, type: :uuid, null: true

    drop_foreign_key :meters, :groups, name: :fk_meters_group
    drop_foreign_key :meters, :addresses, name: :fk_meters_address

    drop_index :meters, [:group_id, :sequence_number]

    SCHEMA.down(:meters, self)
  end
end
