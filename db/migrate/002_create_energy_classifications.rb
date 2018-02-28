class CreateEnergyClassifications < ActiveRecord::Migration

  def change
    create_table :energy_classifications do |t|
      t.string :tariff_name
      t.float :nuclear_ratio, null: false
      t.float :coal_ratio, null: false
      t.float :gas_ratio, null: false
      t.float :other_fossiles_ratio, null: false
      t.float :renewables_eeg_ratio, null: false
      t.float :other_renewables_ratio, null: false
      t.float :co2_emission_gramm_per_kwh, null: false
      t.float :nuclear_waste_miligramm_per_kwh, null: false
      t.date :end_date

      t.belongs_to :organization

      t.timestamps null: false
    end
    add_index :energy_classifications, :organization_id
  end

end
