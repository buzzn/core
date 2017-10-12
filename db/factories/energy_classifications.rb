FactoryGirl.define do
  factory :energy_classification do
    tariff_name                      "Generic Mix"
    organization                     { FactoryGirl.create(:organization) }
    nuclear_ratio                    2.1
    coal_ratio                       5.9
    gas_ratio                        40.9
    other_fossiles_ratio             4.5
    renewables_eeg_ratio             46.5
    other_renewables_ratio           0.1
    co2_emission_gramm_per_kwh       131
    nuclear_waste_miligramm_per_kwh  0.03

    trait :buzzn_energy do
      tariff_name                       'Buzzn Energy'
      organization                      { Organization.find_by(slug: 'buzzn-energy') }
    end

    trait :germany do
      tariff_name                       'Energy Mix Germany'
      organization                      { Organization.find_by(slug: 'germany') }
      nuclear_ratio                     15.4
      coal_ratio                        43.8
      gas_ratio                         6.5
      other_fossiles_ratio              2.5
      renewables_eeg_ratio              28.7
      other_renewables_ratio            3.1
      co2_emission_gramm_per_kwh        476
      nuclear_waste_miligramm_per_kwh   0.4
    end
  end
end
