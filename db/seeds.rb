# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
Time.zone = "Berlin"
require 'rubygems' #so it can load gems



def user_with_location
  location                    = Fabricate(:location)
  contracting_party           = Fabricate(:contracting_party)
  user                        = Fabricate(:user)
  user.contracting_party      = contracting_party
  metering_point              = location.metering_points.first
  metering_point.users        << user
  contracting_party.contracts << metering_point.contract
  user.add_role :manager, location
  return user, location, metering_point
end



puts '-- seed development database --'

puts '  organizations'
Fabricate(:electricity_supplier, name: 'E.ON')
Fabricate(:electricity_supplier, name: 'RWE')
Fabricate(:electricity_supplier, name: 'EnBW')
Fabricate(:electricity_supplier, name: 'Vattenfall')
Fabricate(:metering_service_provider, name: 'Discovergy')
Fabricate(:transmission_system_operator, name: '50Herz')








admin = Fabricate(:admin)
admin.add_role 'admin'

buzzn_team_names = %w[ felix justus danusch thomas martina stefan ole philipp christian ]
buzzn_team = []
puts 'single meters for:'
buzzn_team_names.each do |user_name|
  puts "  #{user_name}"
  buzzn_team << user = Fabricate(user_name)
  case user_name
  when 'justus'
    user_location = Fabricate(:fichtenweg)
  when 'felix'
    user_location = Fabricate(:muehlenkamp)
  when 'stefan'
    @forstenrieder_weg = user_location = Fabricate(:forstenrieder_weg)
  else
    user_location = Fabricate(:location)
  end
  user_location.metering_points.first.users << user
  user.add_role :manager, user_location
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
jan_gerdes.add_role :manager, niensweg



# karin
karin = Fabricate(:karin)
gautinger_weg = Fabricate(:gautinger_weg)
#gautinger_weg.metering_points.first.users << karin
karin.add_role :manager, gautinger_weg
@forstenrieder_weg.metering_points.first.users << karin
buzzn_team.each do |buzzn_user|
  karin.friendships.create(friend: buzzn_user) # alle von buzzn sind freund von karin
  buzzn_user.friendships.create(friend: karin)
end


# felix
felix = User.where(email: 'felix@buzzn.net').first
@forstenrieder_weg.metering_points.first.users << felix




puts '20 more users with location'
20.times do
  user, location, metering_point = user_with_location
  FriendshipRequest.create(sender: buzzn_team[Random.rand(buzzn_team.size)], receiver: user)
  FriendshipRequest.create(sender: buzzn_team[Random.rand(buzzn_team.size)], receiver: user)
  FriendshipRequest.create(sender: buzzn_team[Random.rand(buzzn_team.size)], receiver: user)
  puts "  #{user.email}"
end



puts 'group karin strom'
karins_pv_group = Fabricate(:group, name: 'karins pv strom')
karins_pv_group.metering_points << gautinger_weg.metering_points.first
karin.add_role :manager, karins_pv_group
5.times do
  user, location, metering_point = user_with_location
  karins_pv_group.metering_points << metering_point
  puts "  #{user.email}"
end



puts 'group hof_butenland'
group_hof_butenland = Fabricate(:group_hof_butenland)
group_hof_butenland.metering_points << niensweg.metering_points.first
jan_gerdes.add_role :manager, group_hof_butenland
15.times do
  user, location, metering_point = user_with_location
  group_hof_butenland.metering_points << metering_point
  puts "  #{user.email}"
end




puts '5 simple users'
5.times do
  user = Fabricate(:user)
  puts "  #{user.email}"
end



puts 'add smart meter readings'
date            = Time.now.in_time_zone
start_date      = date.beginning_of_day
end_date        = date.end_of_day
minute          = start_date
watt_hour       = 0
fake_readings   = []
while minute < end_date
  watt_hour += 1
  if (date.middle_of_day..date.middle_of_day+90.minutes).cover?(minute) # from 12:00 to 12:30 is cooking time
    watt_hour += 4000/60
  end
  fake_readings << [minute, watt_hour]
  minute += 1.minute
end
buzzn_team.each do |user|
  Location.with_role(:manager, user).each do |location|
    location.metering_points.each do |metering_point|
      fake_readings.each do |fake_reading|
        Reading.create(
          register_id:  metering_point.registers.in.first.id,
          timestamp:    ActiveSupport::TimeZone["Berlin"].parse(fake_reading.first.to_s),
          watt_hour:    fake_reading.last
        )
      end
    end
  end
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









