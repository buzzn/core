# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
require 'rubygems' #so it can load gems

def user_with_location
  location                    = Fabricate(:location)
  contracting_party           = Fabricate(:contracting_party)
  user                        = Fabricate(:user)
  user.contracting_party      = contracting_party
  metering_point              = location.metering_point
  metering_point.users        << user
  contracting_party.electricity_supplier_contracts << metering_point.electricity_supplier_contracts.first

  user.add_role :manager, location
  return user, location, metering_point
end



puts '-- seed development database --'

puts '  organizations'
Fabricate(:electricity_supplier, name: 'buzzn Energy')
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
Fabricate(:metering_point_operator, name: 'buzzn Metering')
Fabricate(:metering_point_operator, name: 'Discovergy')
Fabricate(:metering_point_operator, name: 'Stadtwerke Augsburg')
Fabricate(:metering_point_operator, name: 'Stadtwerke München')
Fabricate(:metering_point_operator, name: 'Andere')


buzzn_team_names = %w[ felix justus danusch thomas martina stefan ole philipp christian ]
buzzn_team = []
buzzn_team_names.each do |user_name|
  puts "  #{user_name}"
  buzzn_team << user = Fabricate(user_name)
  case user_name
  when 'justus'
    @fichtenweg8  = user_location = Fabricate(:fichtenweg8)

    mp_z1 = Fabricate(:mp_z1)
    mp_z1.metering_point_operator_contracts << Fabricate(:mpoc_buzzn_metering, metering_point: mp_z1)
    user.contracting_party.electricity_supplier_contracts << mp_z1.electricity_supplier_contracts.first
    mp_z2 = Fabricate(:mp_z2)
    mp_z2.metering_point_operator_contracts << Fabricate(:mpoc_buzzn_metering, metering_point: mp_z2)
    user.contracting_party.electricity_supplier_contracts << mp_z2.electricity_supplier_contracts.first
    mp_z3 = Fabricate(:mp_z3)
    mp_z3.metering_point_operator_contracts << Fabricate(:mpoc_buzzn_metering, metering_point: mp_z3)
    user.contracting_party.electricity_supplier_contracts << mp_z3.electricity_supplier_contracts.first
    mp_z4 = Fabricate(:mp_z4)
    mp_z4.metering_point_operator_contracts << Fabricate(:mpoc_buzzn_metering, metering_point: mp_z4)
    user.contracting_party.electricity_supplier_contracts << mp_z4.electricity_supplier_contracts.first
    mp_z5 = Fabricate(:mp_z5)
    mp_z5.metering_point_operator_contracts << Fabricate(:mpoc_buzzn_metering, metering_point: mp_z5)
    user.contracting_party.electricity_supplier_contracts << mp_z5.electricity_supplier_contracts.first

    mp_z2.update_attribute :parent, mp_z1
    mp_z3.update_attribute :parent, mp_z5
    mp_z4.update_attribute :parent, mp_z5
    mp_z5.update_attribute :parent, mp_z2

    user_location.metering_point = mp_z1

    device        = Fabricate(:dach_pv_justus)
    user.add_role :manager, device
    device        = Fabricate(:carport_pv_justus)
    user.add_role :manager, device
    device        = Fabricate(:bhkw_justus)
    user.add_role :manager, device
  when 'felix'
    @gocycle       = Fabricate(:gocycle)
    user.add_role :manager, @gocycle
    user.add_role :admin # felix is admin
    user_location = Fabricate(:urbanstr88)
  when 'christian'
    user_location = Fabricate(:roentgenstrasse11)
    user_location.metering_point.metering_point_operator_contracts << Fabricate(:mpoc_christian, metering_point: user_location.metering_point)
    user.add_role :admin # christian is admin
  when 'philipp'
    user_location = Fabricate(:location_philipp)
    user_location.metering_point.metering_point_operator_contracts << Fabricate(:mpoc_philipp, metering_point: user_location.metering_point)
  when 'stefan'
    @bhkw_stefan       = Fabricate(:bhkw_stefan)
    @forstenrieder_weg = user_location = Fabricate(:forstenrieder_weg)
    @forstenrieder_weg.metering_point.metering_point_operator_contracts << Fabricate(:mpoc_stefan, metering_point: @forstenrieder_weg.metering_point)
    @forstenrieder_weg.metering_point.devices << @bhkw_stefan
    user.add_role :manager, @bhkw_stefan
  else
    user_location = Fabricate(:location)
  end
  user_location.metering_point.users << user
  user.add_role :manager, user_location

  # add user.contracting_party location.metering_point.contracts
  user_location.metering_point.electricity_supplier_contracts.first.contracting_party = user.contracting_party
  user_location.metering_point.electricity_supplier_contracts.first.save

  user_location.create_activity key: 'location.create', owner: user, recipient: user_location
end

puts 'friendships for buzzn team ...'
buzzn_team.each do |user|
  buzzn_team.each do |friend|
    user.friendships.create(friend: friend) if user != friend
  end
end



# hof_butenland
# jan_gerdes = Fabricate(:jan_gerdes)
# niensweg   = Fabricate(:niensweg)
# niensweg.metering_point.metering_point_operator_contracts << Fabricate(:metering_point_operator_contract, metering_point: niensweg.metering_point)
# jan_gerdes.add_role :manager, niensweg
# device = Fabricate(:hof_butenland_wind)
# niensweg.metering_point.devices << device
# jan_gerdes.add_role :manager, device

# niensweg.metering_point.electricity_supplier_contracts.first.contracting_party = jan_gerdes.contracting_party
# niensweg.metering_point.electricity_supplier_contracts.first.save


# karin
karin = Fabricate(:karin)
gautinger_weg = Fabricate(:gautinger_weg)
gautinger_weg.metering_point.metering_point_operator_contracts << Fabricate(:mpoc_karin, metering_point: gautinger_weg.metering_point)
gautinger_weg.metering_point.users << karin
karin.add_role :manager, gautinger_weg
pv_karin = Fabricate(:pv_karin)
karin.add_role :manager, pv_karin
gautinger_weg.metering_point.devices << pv_karin
gautinger_weg.metering_point.electricity_supplier_contracts.first.contracting_party = karin.contracting_party
gautinger_weg.metering_point.electricity_supplier_contracts.first.save

@forstenrieder_weg.metering_point.users << karin


buzzn_team.each do |buzzn_user|
  karin.friendships.create(friend: buzzn_user) # alle von buzzn sind freund von karin
  buzzn_user.friendships.create(friend: karin)
end



# christian_schuetze
christian_schuetze = Fabricate(:christian_schuetze)
fichtenweg10       = Fabricate(:fichtenweg10)
christian_schuetze.add_role :manager, fichtenweg10
fichtenweg10.metering_point.metering_point_operator_contracts << Fabricate(:mpoc_justus, metering_point: fichtenweg10.metering_point)
fichtenweg10.metering_point.users << christian_schuetze
fichtenweg10.metering_point.electricity_supplier_contracts.first.contracting_party = christian_schuetze.contracting_party
fichtenweg10.metering_point.electricity_supplier_contracts.first.save


# felix zieht in forstenrieder_weg ein
felix = User.where(email: 'felix@buzzn.net').first
@forstenrieder_weg.metering_point.users << felix
@forstenrieder_weg.metering_point.devices << @gocycle


# puts '20 more users with location'
# 20.times do
#   user, location, metering_point = user_with_location
#   FriendshipRequest.create(sender: buzzn_team[Random.rand(buzzn_team.size)], receiver: user)
#   FriendshipRequest.create(sender: buzzn_team[Random.rand(buzzn_team.size)], receiver: user)
#   FriendshipRequest.create(sender: buzzn_team[Random.rand(buzzn_team.size)], receiver: user)
#   puts "  #{user.email}"
# end



puts 'group karin strom'
karins_pv_group = Fabricate(:group_karins_pv_strom, metering_points: [gautinger_weg.metering_point])
karin.add_role :manager, karins_pv_group
karins_pv_group.metering_points << User.where(email: 'christian@buzzn.net').first.metering_points.first
karins_pv_group.metering_points << User.where(email: 'felix@buzzn.net').first.metering_points.first
karins_pv_group.metering_points << User.where(email: 'thomas@buzzn.net').first.metering_points.first
karins_pv_group.create_activity key: 'group.create', owner: karin, recipient: karins_pv_group



# puts 'Group Hopf(localpool)'
# hans_dieter_hopf  = Fabricate(:hans_dieter_hopf)
# manuela_baier     = Fabricate(:manuela_baier)
# thomas_hopf       = Fabricate(:thomas_hopf)

# location_manuela_baier = Fabricate(:location_manuela_baier)
# location_thomas_hopf   = Fabricate(:location_thomas_hopf)
# location_hopf = Fabricate(:location_hopf)

# mp_60118470 = Fabricate(:mp_60118470)
# mp_60009316 = Fabricate(:mp_60009316)
# mp_60009272 = location_thomas_hopf.metering_point
# mp_60009348 = location_manuela_baier.metering_point
# mp_hans_dieter_hopf = Fabricate(:mp_hans_dieter_hopf)

# mp_60009272.users         << thomas_hopf
# mp_60009348.users         << manuela_baier
# mp_60009316.users         << hans_dieter_hopf
# mp_hans_dieter_hopf.users << hans_dieter_hopf

# mp_60009316.update_attribute :parent, mp_60118470
# mp_60009272.update_attribute :parent, mp_60118470
# mp_60009348.update_attribute :parent, mp_60118470
# mp_hans_dieter_hopf.update_attribute :parent, mp_60118470

# group_hopf = Fabricate(:group, name: 'Hopf Strom', metering_points: [mp_60118470])
# group_hopf.metering_points << mp_60009316
# group_hopf.metering_points << mp_60009272
# group_hopf.metering_points << mp_60009348
# group_hopf.metering_points << mp_hans_dieter_hopf
# group_hopf.metering_point_operator_contract = Fabricate(:mpoc_buzzn_metering, group: group_hopf)

# puts 'group hof_butenland'
# group_hof_butenland = Fabricate(:group_hof_butenland, metering_points: [niensweg.metering_point])
# jan_gerdes.add_role :manager, group_hof_butenland
# 15.times do
#   user, location, metering_point = user_with_location
#   group_hof_butenland.metering_points << metering_point
#   puts "  #{user.email}"
# end
# group_hof_butenland.create_activity key: 'group.create', owner: jan_gerdes, recipient: group_hof_butenland


#puts 'group home_of_the_brave'
#group_home_of_the_brave = Fabricate(:group_home_of_the_brave, metering_points: [@fichtenweg8.metering_point])
#group_home_of_the_brave.metering_points << fichtenweg10.metering_point
#justus = User.where(email: 'justus@buzzn.net').first
#justus.add_role :manager, group_home_of_the_brave
#group_home_of_the_brave.create_activity key: 'group.create', owner: justus, recipient: group_home_of_the_brave

puts 'group wagnis4'
dirk_mittelstaedt = Fabricate(:dirk_mittelstaedt)
location_dirk_mittelstaedt = Fabricate(:location_dirk_mittelstaedt)
dirk_mittelstaedt.add_role(:manager, location_dirk_mittelstaedt)
mp_60009416 = location_dirk_mittelstaedt.metering_point
mp_60009416.users << dirk_mittelstaedt

manuel_dmoch = Fabricate(:manuel_dmoch)
location_manuel_dmoch = Fabricate(:location_manuel_dmoch)
manuel_dmoch.add_role(:manager, location_manuel_dmoch)
mp_60009419 = location_manuel_dmoch.metering_point
mp_60009419.users << manuel_dmoch

sibo_ahrens = Fabricate(:sibo_ahrens)
location_sibo_ahrens = Fabricate(:location_sibo_ahrens)
sibo_ahrens.add_role(:manager, location_sibo_ahrens)
mp_60009415 = location_sibo_ahrens.metering_point
mp_60009415.users << sibo_ahrens

nicolas_sadoni = Fabricate(:nicolas_sadoni)
location_nicolas_sadoni = Fabricate(:location_nicolas_sadoni)
nicolas_sadoni.add_role(:manager, location_nicolas_sadoni)
mp_60009418 = location_nicolas_sadoni.metering_point
mp_60009418.users << nicolas_sadoni

josef_neu = Fabricate(:josef_neu)
location_josef_neu = Fabricate(:location_josef_neu)
josef_neu.add_role(:manager, location_josef_neu)
mp_60009411 = location_josef_neu.metering_point
mp_60009411.users << josef_neu

elisabeth_christiansen = Fabricate(:elisabeth_christiansen)
location_elisabeth_christiansen = Fabricate(:location_elisabeth_christiansen)
elisabeth_christiansen.add_role(:manager, location_elisabeth_christiansen)
mp_60009410 = location_elisabeth_christiansen.metering_point
mp_60009410.users << elisabeth_christiansen

florian_butz = Fabricate(:florian_butz)
location_florian_butz = Fabricate(:location_florian_butz)
florian_butz.add_role(:manager, location_florian_butz)
mp_60009407 = location_florian_butz.metering_point
mp_60009407.users << florian_butz

ulrike_bez = Fabricate(:ulrike_bez)
location_ulrike_bez = Fabricate(:location_ulrike_bez)
ulrike_bez.add_role(:manager, location_ulrike_bez)
mp_60009409 = location_ulrike_bez.metering_point
mp_60009409.users << ulrike_bez

rudolf_hassenstein = Fabricate(:rudolf_hassenstein)
location_rudolf_hassenstein = Fabricate(:location_rudolf_hassenstein)
rudolf_hassenstein.add_role(:manager, location_rudolf_hassenstein)
mp_60009435 = location_rudolf_hassenstein.metering_point
mp_60009435.users << rudolf_hassenstein

maria_mueller = Fabricate(:maria_mueller)
location_maria_mueller = Fabricate(:location_maria_mueller)
location_wagnis4_laden_eg = Fabricate(:location_wagnis4_laden_eg)
maria_mueller.add_role(:manager, location_maria_mueller)
maria_mueller.add_role(:manager, location_wagnis4_laden_eg)
mp_60009390 = location_wagnis4_laden_eg.metering_point
mp_60009402 = location_maria_mueller.metering_point
mp_60009390.users << maria_mueller
mp_60009402.users << maria_mueller

andreas_schlafer = Fabricate(:andreas_schlafer)
location_andreas_schlafer = Fabricate(:location_andreas_schlafer)
andreas_schlafer.add_role(:manager, location_andreas_schlafer)
mp_60009387 = location_andreas_schlafer.metering_point
mp_60009387.users << andreas_schlafer

luise_woerle = Fabricate(:luise_woerle)
location_luise_woerle = Fabricate(:location_luise_woerle)
luise_woerle.add_role(:manager, location_luise_woerle)
mp_60009438 = location_luise_woerle.metering_point
mp_60009438.users << luise_woerle

peter_waechter = Fabricate(:peter_waechter)
location_peter_waechter = Fabricate(:location_peter_waechter)
peter_waechter.add_role(:manager, location_peter_waechter)
mp_60009440 = location_peter_waechter.metering_point
mp_60009440.users << peter_waechter

sigrid_cycon = Fabricate(:sigrid_cycon)
location_sigrid_cycon = Fabricate(:location_sigrid_cycon)
sigrid_cycon.add_role(:manager, location_sigrid_cycon)
mp_60009404 = location_sigrid_cycon.metering_point
mp_60009404.users << sigrid_cycon

dietlind_klemm = Fabricate(:dietlind_klemm)
location_dietlind_klemm = Fabricate(:location_dietlind_klemm)
dietlind_klemm.add_role(:manager, location_dietlind_klemm)
mp_60009405 = location_dietlind_klemm.metering_point
mp_60009405.users << dietlind_klemm

wilhelm_wagner = Fabricate(:wilhelm_wagner)
location_wilhelm_wagner = Fabricate(:location_wilhelm_wagner)
wilhelm_wagner.add_role(:manager, location_wilhelm_wagner)
mp_60009422 = location_wilhelm_wagner.metering_point
mp_60009422.users << wilhelm_wagner

volker_letzner = Fabricate(:volker_letzner)
location_volker_letzner = Fabricate(:location_volker_letzner)
volker_letzner.add_role(:manager, location_volker_letzner)
mp_60009425 = location_volker_letzner.metering_point
mp_60009425.users << volker_letzner

evang_pflege = Fabricate(:evang_pflege)
location_evang_pflege = Fabricate(:location_evang_pflege)
evang_pflege.add_role(:manager, location_evang_pflege)
mp_60009429 = location_evang_pflege.metering_point
mp_60009429.users << evang_pflege

david_stadlmann = Fabricate(:david_stadlmann)
location_david_stadlmann = Fabricate(:location_david_stadlmann)
david_stadlmann.add_role(:manager, location_david_stadlmann)
mp_60009393 = location_david_stadlmann.metering_point
mp_60009393.users << david_stadlmann

doris_knaier = Fabricate(:doris_knaier)
location_doris_knaier = Fabricate(:location_doris_knaier)
doris_knaier.add_role(:manager, location_doris_knaier)
mp_60009442 = location_doris_knaier.metering_point
mp_60009442.users << doris_knaier

sabine_dumler = Fabricate(:sabine_dumler)
location_sabine_dumler = Fabricate(:location_sabine_dumler)
sabine_dumler.add_role(:manager, location_sabine_dumler)
mp_60009441 = location_sabine_dumler.metering_point
mp_60009441.users << sabine_dumler

location_wagnis4 = Fabricate(:location_wagnis4)
manuel_dmoch.add_role(:manager, location_wagnis4)
mp_60009420 = location_wagnis4.metering_point
#Wagnis 4 - Allgemeinstrom Haus West mp_60009420
#TODO: add real PV metering_point
mp_wagnis = Fabricate(:mp_60118460)
mp_wagnis.parent = location_wagnis4.metering_point
location_wagnis4.metering_point.save
group_wagnis4 = Fabricate(:group_wagnis4, metering_points: [mp_wagnis])
group_wagnis4.metering_points << mp_60009416
group_wagnis4.metering_points << mp_60009419
group_wagnis4.metering_points << mp_60009415
group_wagnis4.metering_points << mp_60009418
group_wagnis4.metering_points << mp_60009411
group_wagnis4.metering_points << mp_60009410
group_wagnis4.metering_points << mp_60009407
group_wagnis4.metering_points << mp_60009409
group_wagnis4.metering_points << mp_60009435
group_wagnis4.metering_points << mp_60009420
group_wagnis4.metering_points << mp_60009390
group_wagnis4.metering_points << mp_60009402
group_wagnis4.metering_points << mp_60009387
group_wagnis4.metering_points << mp_60009438
group_wagnis4.metering_points << mp_60009440
group_wagnis4.metering_points << mp_60009404
group_wagnis4.metering_points << mp_60009405
group_wagnis4.metering_points << mp_60009422
group_wagnis4.metering_points << mp_60009425
group_wagnis4.metering_points << mp_60009429
group_wagnis4.metering_points << mp_60009393
group_wagnis4.metering_points << mp_60009442
group_wagnis4.metering_points << mp_60009441
group_wagnis4.metering_point_operator_contract = Fabricate(:mpoc_buzzn_metering, group: group_wagnis4)








# puts '5 simple users'
# 5.times do
#   user = Fabricate(:user)
#   puts "  #{user.email}"
# end














