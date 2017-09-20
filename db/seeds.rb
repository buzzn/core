# Contains Base configuration and data for a new system.
# Don't add sample data here, add it to sample_data.rb.

puts '-- seed base system data --'

Fabricate(:buzzn_energy)
Fabricate(:dummy_energy)
Fabricate(:germany)
Fabricate(:electricity_supplier, name: 'E.ON')
Fabricate(:electricity_supplier, name: 'RWE')
Fabricate(:electricity_supplier, name: 'EnBW')
Fabricate(:electricity_supplier, name: 'Vattenfall')

Fabricate(:transmission_system_operator, name: '50Hertz Transmission')
Fabricate(:transmission_system_operator, name: 'Tennet TSO')
Fabricate(:transmission_system_operator, name: 'Amprion')
Fabricate(:transmission_system_operator, name: 'TransnetBW')

# Verteilnetzbetreiber (Verteilung an private Haushalte und Kleinverbraucher)
Fabricate(:distribution_system_operator, name: 'Vattenfall Distribution Berlin GmbH')
Fabricate(:distribution_system_operator, name: 'E.ON Bayern AG')
Fabricate(:distribution_system_operator, name: 'RheinEnergie AG')

# Messdienstleistung (Ablesung und Messung)
Fabricate(:buzzn_metering)
Fabricate(:dummy)
Fabricate(:discovergy)
Fabricate(:mysmartgrid)

# Stromkennzeichnungen
Fabricate(:energy_mix_germany)
Fabricate(:energy_mix_buzzn)

[[1, 'Unverified'], [2, 'Verified'], [3, 'Closed']].each do |id, name|
  Account::Status.create!(id: id, name: name)
end

require_relative 'sample_data'
