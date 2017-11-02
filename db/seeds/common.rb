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
# Essential organizations -- which the application requires to work
#

require 'smarter_csv'

module Converters
  class Date
    def self.convert(value)
      ::Date.strptime(value, '%m/%d/%y') # parses custom date format into Date instance
    end
  end
  class Number
    def self.convert(value)
      value.gsub('.', '').to_i
    end
  end
  class PreferredLanguage
    def self.convert(value)
      { 'DE' => :german, 'EN' => :english }[value]
    end
  end
end

def get_csv(model_name, options = {})
  file_name = Rails.root.join("db/seeds/csv/#{model_name}.csv")
  SmarterCSV.process(file_name,
    col_sep: ";",
    convert_values_to_numeric: false,
    value_converters: options[:converters]
  )
end

def import_csv(model_name, options = {})
  hashes = get_csv(model_name, options)
  selected_hashes = options[:only] ? hashes.select(&options[:only]) : hashes
  selected_hashes.each do |hash|
    label = hash[:name] || "#{hash[:first_name]} #{hash[:last_name]}"
    puts "Loading #{model_name.to_s.singularize} #{label}"
    klass = model_name.to_s.singularize.camelize.constantize
    record = klass.create(hash)
    unless record.persisted?
      ap record
      ap record.errors
    end
  end
end

import_csv(:persons, converters: { preferred_language: Converters::PreferredLanguage })

import_csv(:organizations)

Organization.buzzn   = Organization.find_by(slug: "buzzn")
Organization.buzzn.energy_classifications = [ energy_classifications[:buzzn] ]
Organization.germany = Organization.find_by(slug: "germany")
Organization.germany.energy_classifications = [ energy_classifications[:germany] ]

get_csv(:organization_market_functions).each do |row|
  begin
    organization = Organization.find_by(name: row[:organization_id])
    unless organization
      puts "Unable to find organization #{row[:organization_id]} for assigning market function."
      next
    end
    contact = Person.find_by(last_name: row[:contact_person_id])
    organization.market_functions.create!(row.except(:organization_id).merge(contact_person: contact))
    puts "Assigned market function #{row[:function]} to #{row[:organization_id]}"
  rescue => e
    ap e
    ap row
    ap organization
  end
end
