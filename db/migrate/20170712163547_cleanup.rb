class Cleanup < ActiveRecord::Migration

  def up
    remove_column :devices, :readable
    remove_column :devices, :slug

    rename_column :energy_classifications, :co2_emission_gramm_per_kWh, :co2_emission_gramm_per_kwh
    rename_column :energy_classifications, :nuclear_waste_miligramm_per_kWh, :nuclear_waste_miligramm_per_kwh
  end

end
