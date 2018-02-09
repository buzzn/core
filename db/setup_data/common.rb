Buzzn::Logger.root.info 'seeds: loading common setup data'

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
    tariff_name:                      'Buzzn GmbH',
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
# Organizations
#

require 'smarter_csv'

module Converters
  class PreferredLanguage
    def self.convert(value)
      { 'DE' => :german, 'EN' => :english }[value]
    end
  end
  class State
    def self.convert(value)
      "DE_#{value}"
    end
  end
end

def get_csv(model_name, options = {})
  file_name = "db/setup_data/csv/#{model_name}.csv"
  SmarterCSV.process(file_name,
    col_sep: ',',
    convert_values_to_numeric: false,
    value_converters: options[:converters]
  )
end

def import_csv(model_name, options = {})
  hashes = get_csv(model_name, options)
  selected_hashes = options[:only] ? hashes.select(&options[:only]) : hashes
  selected_hashes.each.with_index do |hash, index|
    label = hash[:name] || "#{hash[:first_name]} #{hash[:last_name]}"
    Buzzn::Logger.root.debug "Loading #{model_name.to_s.singularize} #{label}"
    klass = model_name.to_s.singularize.camelize.constantize
    hash[:email] = hash[:email].sub(/unknown@/, "unknown#{index}")
    record = klass.create(hash)
    unless record.persisted?
      ap record
      ap record.errors
    end
  end
end

import_csv(:persons, converters: { preferred_language: Converters::PreferredLanguage })

ADDRESS_ATTRIBUTES = %i(street city zip country)
get_csv(:organizations, converters: { state: Converters::State }).each do |row|
  Buzzn::Logger.root.debug "Loading organization #{row[:name]}"
  address_attrs = row.slice(*ADDRESS_ATTRIBUTES)
  org_attrs     = row.except(*(ADDRESS_ATTRIBUTES + [:state]))
  record        = Organization.new(org_attrs)
  if ADDRESS_ATTRIBUTES.all? { |attr| address_attrs[attr].present? }
    record.build_address(address_attrs)
  else
    Buzzn::Logger.root.debug "Warning: address attributes for #{row[:name]} not present or incomplete; skipping address creation."
  end
  unless record.save!
    ap record
    ap record.errors
  end
end

# Assigning buzzn and germany here is essential for the application to work!
Organization.buzzn = Organization.find_by(slug: 'buzzn')
Organization.buzzn.energy_classifications = [ energy_classifications[:buzzn] ]
Organization.germany = Organization.find_by(slug: 'germany')
Organization.germany.energy_classifications = [ energy_classifications[:germany] ]

get_csv(:organization_market_functions).each do |row|
  begin
    organization = Organization.find_by(name: row[:organization_id])
    unless organization
      Buzzn::Logger.root.debug "Unable to find organization #{row[:organization_id]} for assigning market function."
      next
    end
    contact = Person.find_by(last_name: row[:contact_person_id])
    organization.market_functions.create!(row.except(:organization_id).merge(contact_person: contact))
    Buzzn::Logger.root.debug "Assigned market function #{row[:function]} to #{row[:organization_id]}"
  rescue => e
    ap e
    ap row
    ap organization
  end
end
