require_relative 'common_seeds'

Organization.delete_all
Fabricate(:dummy)
Fabricate(:dummy_energy)
Fabricate(:discovergy)
Fabricate(:buzzn_energy)
Fabricate(:buzzn_systems)
Fabricate(:mysmartgrid)
Fabricate(:germany)
