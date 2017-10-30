require_relative 'common'

Organization.delete_all
Organization.reset_cache

Fabricate(:discovergy)
# replaced with buzzn
# Fabricate(:buzzn_energy)
# Fabricate(:buzzn_systems)
Fabricate(:mysmartgrid)
Fabricate(:germany)

# before running specs, DB is always cleaned.
# PersonsRole.delete_all
# Role.delete_all
# Account::PasswordHash.delete_all
# Account::PasswordResetKey.delete_all
# Account::LoginChangeKey.delete_all
# Account::Base.delete_all
# Person.delete_all

$admin = Fabricate(:admin)
$user  = Fabricate(:user)
$other = Fabricate(:user)
