class AddLegacyBuzznidToMeters < ActiveRecord::Migration
  def change
    add_column :meters, :legacy_buzznid, :string
  end
end
