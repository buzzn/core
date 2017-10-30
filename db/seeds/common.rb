puts "seeds: loading common setup data"

#
# Account statuses
#
[[1, 'Unverified'], [2, 'Verified'], [3, 'Closed']].each do |id, name|
  Account::Status.create!(id: id, name: name)
end

#
# Energy classifications
#
energy_classifications = {
  buzzn: EnergyClassification.create!(
    tariff_name:                      "Buzzn GmbH",
    nuclear_ratio:                    2.1,
    coal_ratio:                       5.9,
    gas_ratio:                        40.9,
    other_fossiles_ratio:             4.5,
    renewables_eeg_ratio:             46.5,
    other_renewables_ratio:           0.1,
    co2_emission_gramm_per_kwh:       131,
    nuclear_waste_miligramm_per_kwh:  0.03
  ),
  germany: EnergyClassification.create!(
    tariff_name:                       'Energy Mix Germany',
    nuclear_ratio:                     15.4,
    coal_ratio:                        43.8,
    gas_ratio:                         6.5,
    other_fossiles_ratio:              2.5,
    renewables_eeg_ratio:              28.7,
    other_renewables_ratio:            3.1,
    co2_emission_gramm_per_kwh:        476,
    nuclear_waste_miligramm_per_kwh:   0.4
  )
}

#
# Organizations the application requires to work
#
Organization.buzzn = Organization.create!(
  name: 'Buzzn GmbH',
  description: 'Purveyor of peoplepower since 2009',
  slug: 'buzzn',
  email: 'dev+buzzn@buzzn.net',
  phone: '089 / 32 16 8',
  website: 'www.buzzn.net',
  energy_classifications: [ energy_classifications[:buzzn] ],
  # FIXME
  # address: FactoryGirl.build(:address),
  # contact: FactoryGirl.build(:person)
)
Organization.buzzn.market_functions.create!(
  function: :electricity_supplier,
  market_partner_id: "9905229000008",
  edifact_email: "justus@buzzn.net",
  address: Organization.buzzn.address,
  contact_person: Organization.buzzn.contact
)

Organization.germany = Organization.create!(
  name: 'Germany Energy Mix',
  description: 'used for energy mix \'Germany\'',
  slug: 'germany',
  email: 'dev+org-germany@buzzn.net',
  phone: '040 12345',
  energy_classifications: [ energy_classifications[:germany] ],
  # FIXME
  address: Organization.buzzn.address,
  contact: Organization.buzzn.contact
)
