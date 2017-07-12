class Cleanup < ActiveRecord::Migration
  def up
    remove_column :addresses, :readable
    remove_column :addresses, :slug
    remove_column :devices, :readable
    remove_column :devices, :slug

    rename_column :energy_classifications, :co2_emission_gramm_per_kWh, :co2_emission_gramm_per_kwh
    rename_column :energy_classifications, :nuclear_waste_miligramm_per_kWh, :nuclear_waste_miligramm_per_kwh
    rename_column :billings, :total_energy_consumption_kWh, :total_energy_consumption_kwh
    drop_table :activities
    drop_table :badge_notifications
    drop_table :conversations
    drop_table :friendly_id_slugs
    drop_table :taggings
    drop_table :tags
    drop_table :versions
    drop_table :votes
  end
end
