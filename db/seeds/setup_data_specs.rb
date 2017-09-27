require_relative 'setup_data_common'

puts "seeds: loading spec setup data"
Organization.delete_all
Fabricate(:dummy)
Fabricate(:dummy_energy)
Fabricate(:discovergy)
Fabricate(:buzzn_energy)
Fabricate(:buzzn_systems)
Fabricate(:mysmartgrid)
Fabricate(:germany)
