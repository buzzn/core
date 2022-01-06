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
  buzzn: Organization::EnergyClassification.create!(
    tariff_name:                      'Buzzn GmbH',
    nuclear_ratio:                    0,
    coal_ratio:                       0,
    gas_ratio:                        38.8,
    other_fossiles_ratio:             0,
    renewables_eeg_ratio:             27.5,
    other_renewables_ratio:           33.7,
    co2_emission_gramm_per_kwh:       91,
    nuclear_waste_miligramm_per_kwh:  0
  ),
  germany: Organization::EnergyClassification.create!(
    tariff_name:                       'Energy Mix Germany',
    nuclear_ratio:                     12.4,
    coal_ratio:                        24,
    gas_ratio:                         13.3,
    other_fossiles_ratio:              1.3,
    renewables_eeg_ratio:              44.9,
    other_renewables_ratio:            4.1,
    co2_emission_gramm_per_kwh:        310,
    nuclear_waste_miligramm_per_kwh:   0.3
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
  record        = Organization::Market.new(org_attrs)
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
Organization::Market.buzzn.energy_classifications = [energy_classifications[:buzzn]]
Organization::Market.germany.energy_classifications = [energy_classifications[:germany]]

get_csv(:organization_market_functions).each do |row|
  begin
    organization = Organization::Market.find_by(name: row[:organization_id])
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
