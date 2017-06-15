class RemoveAttributesFromMeters < ActiveRecord::Migration
  def change
    remove_column :meters, :mode, :string
    remove_column :meters, :slug, :string
    remove_column :meters, :smart, :string
    remove_column :meters, :metering_point_type, :string
  end
end
