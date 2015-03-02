# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
require 'rubygems' #so it can load gems

def user_with_metering_point
  metering_point              = Fabricate(:metering_point_with_address)
  contracting_party           = Fabricate(:contracting_party)
  user                        = Fabricate(:user)
  user.contracting_party      = contracting_party
  metering_point.users        << user
  contracting_party.contracts << metering_point.contracts.electricity_suppliers.first

  user.add_role :manager, metering_point
  return user, metering_point
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
    @fichtenweg8 = root_mp = mp_z1 = Fabricate(:mp_z1)
    mp_z1.contracts << Fabricate(:mpoc_buzzn_metering, metering_point: mp_z1)
    user.contracting_party.contracts << mp_z1.contracts.metering_point_operators.first
    mp_z2 = Fabricate(:mp_z2)
    mp_z2.contracts << Fabricate(:mpoc_buzzn_metering, metering_point: mp_z2)
    user.contracting_party.contracts << mp_z2.contracts.metering_point_operators.first
    mp_z3 = Fabricate(:mp_z3)
    mp_z3.contracts << Fabricate(:mpoc_buzzn_metering, metering_point: mp_z3)
    user.contracting_party.contracts << mp_z3.contracts.metering_point_operators.first
    mp_z4 = Fabricate(:mp_z4)
    mp_z4.contracts << Fabricate(:mpoc_buzzn_metering, metering_point: mp_z4)
    user.contracting_party.contracts << mp_z4.contracts.metering_point_operators.first
    mp_z5 = Fabricate(:mp_z5)
    mp_z5.contracts << Fabricate(:mpoc_buzzn_metering, metering_point: mp_z5)
    user.contracting_party.contracts << mp_z5.contracts.metering_point_operators.first

    mp_z2.update_attribute :parent, mp_z1
    mp_z3.update_attribute :parent, mp_z5
    mp_z4.update_attribute :parent, mp_z5
    mp_z5.update_attribute :parent, mp_z2

    dach_pv_justus = Fabricate(:dach_pv_justus)
    mp_z2.devices << dach_pv_justus
    user.add_role :manager, dach_pv_justus

    bhkw_justus        = Fabricate(:bhkw_justus)
    mp_z4.devices << bhkw_justus
    user.add_role :manager, bhkw_justus

    auto_justus        = Fabricate(:auto_justus)
    mp_z3.devices << auto_justus
    user.add_role :manager, auto_justus

  when 'felix'
    @gocycle       = Fabricate(:gocycle)
    user.add_role :manager, @gocycle
    user.add_role :admin # felix is admin
    root_mp = Fabricate(:mp_urbanstr88)
    root_mp.devices << @gocycle
  when 'christian'
    root_mp = Fabricate(:mp_60138988)
    root_mp.contracts << Fabricate(:mpoc_christian, metering_point: root_mp)
    user.add_role :admin # christian is admin
  when 'philipp'
    root_mp = Fabricate(:mp_60009269)
    root_mp.contracts << Fabricate(:mpoc_philipp, metering_point: root_mp)
  when 'stefan'
    @bhkw_stefan       = Fabricate(:bhkw_stefan)
    @forstenrieder_weg_mp = root_mp = Fabricate(:mp_stefans_bhkw)
    root_mp.contracts << Fabricate(:mpoc_stefan, metering_point: root_mp)
    root_mp.devices << @bhkw_stefan
    user.add_role :manager, @bhkw_stefan
  else
    root_mp = Fabricate(:metering_point)
  end
  user.add_role :manager, root_mp
  root_mp.users << user
  root_mp.contracts.electricity_suppliers.first.contracting_party = user.contracting_party
  root_mp.contracts.electricity_suppliers.first.save
end

puts 'friendships for buzzn team ...'
buzzn_team.each do |user|
  buzzn_team.each do |friend|
    user.friendships.create(friend: friend) if user != friend
  end
end



#hof_butenland
jan_gerdes = Fabricate(:jan_gerdes)
mp_hof_butenland_wind   = Fabricate(:mp_hof_butenland_wind)
mp_hof_butenland_wind.contracts << Fabricate(:mpoc_buzzn_metering, metering_point: mp_hof_butenland_wind)
jan_gerdes.add_role :manager, mp_hof_butenland_wind
device = Fabricate(:hof_butenland_wind)
mp_hof_butenland_wind.devices << device
jan_gerdes.add_role :manager, device

mp_hof_butenland_wind.contracts.metering_point_operators.first.contracting_party = jan_gerdes.contracting_party
mp_hof_butenland_wind.contracts.metering_point_operators.first.save


# karin
karin = Fabricate(:karin)
mp_pv_karin = Fabricate(:mp_pv_karin)
mp_pv_karin.contracts << Fabricate(:mpoc_karin, metering_point: mp_pv_karin)
mp_pv_karin.users << karin
karin.add_role :manager, mp_pv_karin
pv_karin = Fabricate(:pv_karin)
karin.add_role :manager, pv_karin
mp_pv_karin.devices << pv_karin
mp_pv_karin.contracts.metering_point_operators.first.contracting_party = karin.contracting_party
mp_pv_karin.contracts.metering_point_operators.first.save

@forstenrieder_weg_mp.users << karin


buzzn_team.each do |buzzn_user|
  karin.friendships.create(friend: buzzn_user) # alle von buzzn sind freund von karin
  buzzn_user.friendships.create(friend: karin)
end



# christian_schuetze
christian_schuetze = Fabricate(:christian_schuetze)
@fichtenweg10 = mp_cs_1 = Fabricate(:mp_cs_1)
christian_schuetze.add_role :manager, mp_cs_1
mp_cs_1.contracts << Fabricate(:mpoc_justus, metering_point: mp_cs_1)
mp_cs_1.users << christian_schuetze
mp_cs_1.contracts.metering_point_operators.first.contracting_party = christian_schuetze.contracting_party
mp_cs_1.contracts.metering_point_operators.first.save



# puts '20 more users with location'
# 20.times do
#   user, location, metering_point = user_with_location
#   FriendshipRequest.create(sender: buzzn_team[Random.rand(buzzn_team.size)], receiver: user)
#   FriendshipRequest.create(sender: buzzn_team[Random.rand(buzzn_team.size)], receiver: user)
#   FriendshipRequest.create(sender: buzzn_team[Random.rand(buzzn_team.size)], receiver: user)
#   puts "  #{user.email}"
# end



puts 'group karin strom'
karins_pv_group = Fabricate(:group_karins_pv_strom, metering_points: [mp_pv_karin])
karin.add_role :manager, karins_pv_group
karins_pv_group.metering_points << User.where(email: 'christian@buzzn.net').first.metering_points.first
karins_pv_group.metering_points << User.where(email: 'felix@buzzn.net').first.metering_points.first
karins_pv_group.metering_points << User.where(email: 'thomas@buzzn.net').first.metering_points.first
karins_pv_group.create_activity key: 'group.create', owner: karin, recipient: karins_pv_group



puts 'Group Hopf(localpool)'
hans_dieter_hopf  = Fabricate(:hans_dieter_hopf)
manuela_baier     = Fabricate(:manuela_baier)
thomas_hopf       = Fabricate(:thomas_hopf)

mp_60118470 = Fabricate(:mp_60118470)
mp_60009316 = Fabricate(:mp_60009316)
mp_60009272 = Fabricate(:mp_60009272)
mp_60009348 = Fabricate(:mp_60009348)
mp_hans_dieter_hopf = Fabricate(:mp_hans_dieter_hopf)

mp_60009272.users         << thomas_hopf
mp_60009348.users         << manuela_baier
mp_60009316.users         << hans_dieter_hopf
mp_hans_dieter_hopf.users << hans_dieter_hopf

mp_60009316.update_attribute :parent, mp_60118470
mp_60009272.update_attribute :parent, mp_60118470
mp_60009348.update_attribute :parent, mp_60118470
mp_hans_dieter_hopf.update_attribute :parent, mp_60118470

group_hopf = Fabricate(:group, name: 'Hopf Strom', metering_points: [mp_60118470])
group_hopf.metering_points << mp_60009316
group_hopf.metering_points << mp_60009272
group_hopf.metering_points << mp_60009348
group_hopf.metering_points << mp_hans_dieter_hopf
group_hopf.contracts << Fabricate(:mpoc_buzzn_metering, group: group_hopf)



puts 'group hof_butenland'
group_hof_butenland = Fabricate(:group_hof_butenland, metering_points: [mp_hof_butenland_wind])
jan_gerdes.add_role :manager, group_hof_butenland
15.times do
  user, metering_point = user_with_metering_point
  group_hof_butenland.metering_points << metering_point
  puts "  #{user.email}"
end


puts 'group home_of_the_brave'
group_home_of_the_brave = Fabricate(:group_home_of_the_brave, metering_points: [@fichtenweg8])
group_home_of_the_brave.metering_points << @fichtenweg10
justus = User.where(email: 'justus@buzzn.net').first
justus.add_role :manager, group_home_of_the_brave
group_home_of_the_brave.create_activity key: 'group.create', owner: justus, recipient: group_home_of_the_brave



puts 'group wagnis4'
dirk_mittelstaedt = Fabricate(:dirk_mittelstaedt)
mp_60009416 = Fabricate(:mp_60009416)
dirk_mittelstaedt.add_role(:manager, mp_60009416)
mp_60009416.users << dirk_mittelstaedt

manuel_dmoch = Fabricate(:manuel_dmoch)
mp_60009419 = Fabricate(:mp_60009419)
manuel_dmoch.add_role(:manager, mp_60009419)
mp_60009419.users << manuel_dmoch

sibo_ahrens = Fabricate(:sibo_ahrens)
mp_60009415 = Fabricate(:mp_60009415)
sibo_ahrens.add_role(:manager, mp_60009415)
mp_60009415.users << sibo_ahrens

nicolas_sadoni = Fabricate(:nicolas_sadoni)
mp_60009418 = Fabricate(:mp_60009418)
nicolas_sadoni.add_role(:manager, mp_60009418)
mp_60009418.users << nicolas_sadoni

josef_neu = Fabricate(:josef_neu)
mp_60009411 = Fabricate(:mp_60009411)
josef_neu.add_role(:manager, mp_60009411)
mp_60009411.users << josef_neu

elisabeth_christiansen = Fabricate(:elisabeth_christiansen)
mp_60009410 = Fabricate(:mp_60009410)
elisabeth_christiansen.add_role(:manager, mp_60009410)
mp_60009410.users << elisabeth_christiansen

florian_butz = Fabricate(:florian_butz)
mp_60009407 = Fabricate(:mp_60009407)
florian_butz.add_role(:manager, mp_60009407)
mp_60009407.users << florian_butz

ulrike_bez = Fabricate(:ulrike_bez)
mp_60009409 = Fabricate(:mp_60009409)
ulrike_bez.add_role(:manager, mp_60009409)
mp_60009409.users << ulrike_bez

rudolf_hassenstein = Fabricate(:rudolf_hassenstein)
mp_60009435 = Fabricate(:mp_60009435)
rudolf_hassenstein.add_role(:manager, mp_60009435)
mp_60009435.users << rudolf_hassenstein

maria_mueller = Fabricate(:maria_mueller)
mp_60009402 = Fabricate(:mp_60009402)
mp_60009390 = Fabricate(:mp_60009390)
maria_mueller.add_role(:manager, mp_60009402)
maria_mueller.add_role(:manager, mp_60009390)
mp_60009402.users << maria_mueller
mp_60009390.users << maria_mueller

andreas_schlafer = Fabricate(:andreas_schlafer)
mp_60009387 = Fabricate(:mp_60009387)
andreas_schlafer.add_role(:manager, mp_60009387)
mp_60009387.users << andreas_schlafer

luise_woerle = Fabricate(:luise_woerle)
mp_60009438 = Fabricate(:mp_60009438)
luise_woerle.add_role(:manager, mp_60009438)
mp_60009438.users << luise_woerle

peter_waechter = Fabricate(:peter_waechter)
mp_60009440 = Fabricate(:mp_60009440)
peter_waechter.add_role(:manager, mp_60009440)
mp_60009440.users << peter_waechter

sigrid_cycon = Fabricate(:sigrid_cycon)
mp_60009404 = Fabricate(:mp_60009404)
sigrid_cycon.add_role(:manager, mp_60009404)
mp_60009404.users << sigrid_cycon

dietlind_klemm = Fabricate(:dietlind_klemm)
mp_60009405 = Fabricate(:mp_60009405)
dietlind_klemm.add_role(:manager, mp_60009405)
mp_60009405.users << dietlind_klemm

wilhelm_wagner = Fabricate(:wilhelm_wagner)
mp_60009422 = Fabricate(:mp_60009422)
wilhelm_wagner.add_role(:manager, mp_60009422)
mp_60009422.users << wilhelm_wagner

volker_letzner = Fabricate(:volker_letzner)
mp_60009425 = Fabricate(:mp_60009425)
volker_letzner.add_role(:manager, mp_60009425)
mp_60009425.users << volker_letzner

evang_pflege = Fabricate(:evang_pflege)
mp_60009429 = Fabricate(:mp_60009429)
evang_pflege.add_role(:manager, mp_60009429)
mp_60009429.users << evang_pflege

david_stadlmann = Fabricate(:david_stadlmann)
mp_60009393 = Fabricate(:mp_60009393)
david_stadlmann.add_role(:manager, mp_60009393)
mp_60009393.users << david_stadlmann

doris_knaier = Fabricate(:doris_knaier)
mp_60009442 = Fabricate(:mp_60009442)
doris_knaier.add_role(:manager, mp_60009442)
mp_60009442.users << doris_knaier

sabine_dumler = Fabricate(:sabine_dumler)
mp_60009441 = Fabricate(:mp_60009441)
sabine_dumler.add_role(:manager, mp_60009441)
mp_60009441.users << sabine_dumler

mp_60009420 = Fabricate(:mp_60009420)
manuel_dmoch.add_role(:manager, mp_60009420)
#Wagnis 4 - Allgemeinstrom Haus West mp_60009420
#TODO: add real PV metering_point
mp_60118460 = Fabricate(:mp_60118460)
mp_60118460.parent = mp_60009420
mp_60009420.save
group_wagnis4 = Fabricate(:group_wagnis4, metering_points: [mp_60118460])
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
group_wagnis4.contracts       << Fabricate(:mpoc_buzzn_metering, group: group_wagnis4)




puts '5 simple users'
5.times do
  user = Fabricate(:user)
  puts "  #{user.email}"
end














