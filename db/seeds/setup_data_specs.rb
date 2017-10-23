require_relative 'setup_data_common'

puts "seeds: loading spec setup data"
Organization.delete_all
Organization.reset_cache

$admin = Fabricate(:admin)
$user  = Fabricate(:user)
$other = Fabricate(:user)

__END__

# Christian's state, to be merged with my changes
Fabricate(:dummy)
Fabricate(:dummy_energy)
Fabricate(:discovergy)
Fabricate(:buzzn_energy)
Fabricate(:buzzn_systems)
Fabricate(:mysmartgrid)
Fabricate(:germany)

PersonsRole.delete_all
Role.delete_all
Account::PasswordHash.delete_all
Account::PasswordResetKey.delete_all
Account::LoginChangeKey.delete_all
Account::Base.delete_all
Person.delete_all
