Fabricator(:new_energy_classification, class_name: 'EnergyClassification') do
  tariff_name                      "Generic Mix"
  # TODO add organization
  # organization                     "Generic Organization"
  nuclear_ratio                    2.1
  coal_ratio                       5.9
  gas_ratio                        40.9
  other_fossiles_ratio             4.5
  renewables_eeg_ratio             46.5
  other_renewables_ratio           0.1
  co2_emission_gramm_per_kwh       131
  nuclear_waste_miligramm_per_kwh  0.03
end
