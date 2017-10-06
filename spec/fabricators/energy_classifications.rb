# coding: utf-8
Fabricator :energy_classification, from: EnergyClassification do
  tariff_name { FFaker::Name.name.slice(0...30) }
  nuclear_ratio { 10.0 }
  coal_ratio { 10.0 }
  gas_ratio { 20.0 }
  other_fossiles_ratio { 20.0 }
  renewables_eeg_ratio { 20.0 }
  other_renewables_ratio { 20.0 }
  co2_emission_gramm_per_kwh { 104.0 }
  nuclear_waste_miligramm_per_kwh { 0.4 }
  created_at  { (rand*10).days.ago }
end

Fabricator :energy_mix_germany, from: :energy_classification do
  tariff_name { 'energy mix germany' }
  nuclear_ratio { 15.4 }
  coal_ratio { 43.8 }
  gas_ratio { 6.5 }
  other_fossiles_ratio { 2.5 }
  renewables_eeg_ratio { 28.7 }
  other_renewables_ratio { 3.1 }
  co2_emission_gramm_per_kwh { 476.0 }
  nuclear_waste_miligramm_per_kwh { 0.4 }
  organization { Organization.germany }
end

Fabricator :energy_mix_buzzn, from: :energy_classification do
  tariff_name { 'buzzn' }
  nuclear_ratio { 2.1 }
  coal_ratio { 5.9 }
  gas_ratio { 40.9 }
  other_fossiles_ratio { 4.5 }
  renewables_eeg_ratio { 46.5 }
  other_renewables_ratio { 0.1 }
  co2_emission_gramm_per_kwh { 131.0 }
  nuclear_waste_miligramm_per_kwh { 0.03 }
  organization { Organization.buzzn_energy }
end

Fabricator :sulz_supplier_mix, from: :energy_classification do
  tariff_name { 'Gemeindewerke Peißenberg' }
  nuclear_ratio { 9.3 }
  coal_ratio { 36.1 }
  gas_ratio { 7.9 }
  other_fossiles_ratio { 1 }
  renewables_eeg_ratio { 45.5 }
  other_renewables_ratio { 0.2 }
  co2_emission_gramm_per_kwh { 427.0 }
  nuclear_waste_miligramm_per_kwh { 0.25 }
  organization { Organization.gemeindewerke_peissenberg }
end
