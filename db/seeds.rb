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
    mp_z2 = Fabricate(:mp_z2)
    mp_z3 = Fabricate(:mp_z3)
    mp_z4 = Fabricate(:mp_z4)
    mp_z5 = Fabricate(:mp_z5)

    mp_z2.update_attribute :parent, mp_z1
    mp_z3.update_attribute :parent, mp_z1
    mp_z4.update_attribute :parent, mp_z1
    mp_z5.update_attribute :parent, mp_z1

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
    user_location = Fabricate(:muehlenkamp)
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
jan_gerdes = Fabricate(:jan_gerdes)
niensweg   = Fabricate(:niensweg)
niensweg.metering_point.metering_point_operator_contracts << Fabricate(:metering_point_operator_contract, metering_point: niensweg.metering_point)
jan_gerdes.add_role :manager, niensweg
device = Fabricate(:hof_butenland_wind)
niensweg.metering_point.devices << device
jan_gerdes.add_role :manager, device

niensweg.metering_point.electricity_supplier_contracts.first.contracting_party = jan_gerdes.contracting_party
niensweg.metering_point.electricity_supplier_contracts.first.save


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


puts '20 more users with location'
20.times do
  user, location, metering_point = user_with_location
  FriendshipRequest.create(sender: buzzn_team[Random.rand(buzzn_team.size)], receiver: user)
  FriendshipRequest.create(sender: buzzn_team[Random.rand(buzzn_team.size)], receiver: user)
  FriendshipRequest.create(sender: buzzn_team[Random.rand(buzzn_team.size)], receiver: user)
  puts "  #{user.email}"
end



puts 'group karin strom'
karins_pv_group = Fabricate(:group_karins_pv_strom, metering_points: [gautinger_weg.metering_point])
karin.add_role :manager, karins_pv_group
karins_pv_group.metering_points << User.where(email: 'christian@buzzn.net').first.metering_points.first
karins_pv_group.metering_points << User.where(email: 'felix@buzzn.net').first.metering_points.first
karins_pv_group.metering_points << User.where(email: 'thomas@buzzn.net').first.metering_points.first
karins_pv_group.create_activity key: 'group.create', owner: karin, recipient: karins_pv_group



puts 'Group Hopf(localpool)'
hans_dieter_hopf  = Fabricate(:hans_dieter_hopf)

mp_60118470 = Fabricate(:mp_60118470)
mp_60009316 = Fabricate(:mp_60009316)
mp_60009272 = Fabricate(:mp_60009272)
mp_60009348 = Fabricate(:mp_60009348)
mp_hans_dieter_hopf = Fabricate(:mp_hans_dieter_hopf)

mp_60009316.update_attribute :parent, mp_60118470
mp_60009272.update_attribute :parent, mp_60118470
mp_60009348.update_attribute :parent, mp_60118470
mp_hans_dieter_hopf.update_attribute :parent, mp_60118470

location_hopf = Fabricate(:location_hopf)
location_hopf.metering_point = mp_60118470

group_hopf = Fabricate(:group, name: 'Hopf Strom', metering_points: [mp_60118470])
group_hopf.metering_points << mp_60009316
group_hopf.metering_points << mp_60009272
group_hopf.metering_points << mp_60009348
group_hopf.metering_points << mp_hans_dieter_hopf
group_hopf.metering_point_operator_contract = Fabricate(:mpoc_buzzn_metering, group: group_hopf)

puts 'group hof_butenland'
group_hof_butenland = Fabricate(:group_hof_butenland, metering_points: [niensweg.metering_point])
jan_gerdes.add_role :manager, group_hof_butenland
15.times do
  user, location, metering_point = user_with_location
  group_hof_butenland.metering_points << metering_point
  puts "  #{user.email}"
end
group_hof_butenland.create_activity key: 'group.create', owner: jan_gerdes, recipient: group_hof_butenland


puts 'group home_of_the_brave'
group_home_of_the_brave = Fabricate(:group_home_of_the_brave, metering_points: [@fichtenweg8.metering_point])
group_home_of_the_brave.metering_points << fichtenweg10.metering_point
justus = User.where(email: 'justus@buzzn.net').first
justus.add_role :manager, group_home_of_the_brave
group_home_of_the_brave.create_activity key: 'group.create', owner: justus, recipient: group_home_of_the_brave






puts '5 simple users'
5.times do
  user = Fabricate(:user)
  puts "  #{user.email}"
end




puts "Creating SLP"
infile = File.new("#{Rails.root}/db/MSCONS_TL_9907399000009_9905229000008_20130920_40010113207322_RH0.txt", "r")
all_lines = infile.readline
infile.close
watt_hour = 0.0
while true do
  posOfSeperator = all_lines.index("'")
  if posOfSeperator == nil
    break
  else
    parseString = all_lines[0...posOfSeperator]
    all_lines = all_lines[(posOfSeperator + 1)..all_lines.length]
    if parseString.include? "DTM+163"
      remString = parseString[8..parseString.length]
      dateString = remString[0..3] + "-" + remString[4..5] + "-" + remString[6..7] + " " + remString[8..9] + ":" + remString[10..11]
      Reading.create(
        timestamp: ActiveSupport::TimeZone["Berlin"].parse(dateString),
        watt_hour: watt_hour,
        source: "slp"
      )
    elsif parseString.include? "QTY"
      watt_hour += parseString[8...parseString.length].to_f
      watt_hour = watt_hour.round(3)
    end
  end
end










