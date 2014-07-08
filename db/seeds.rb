# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

require 'rubygems' #so it can load gems

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
    user_location = Fabricate(:location)#Fabricate(:location_fichtenweg)
  when 'felix'
    user_location = Fabricate(:location_muehlenkamp)
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



puts '20 more users with location'
20.times do
  location                    = Fabricate(:location)
  contracting_party           = Fabricate(:contracting_party)
  user                        = Fabricate(:user)
  user.contracting_party      = contracting_party
  metering_point              = location.metering_points.first
  metering_point.users        << user
  contracting_party.contracts << metering_point.contract
  user.add_role :manager, location
  FriendshipRequest.create(sender: buzzn_team[Random.rand(buzzn_team.size)], receiver: user)
  FriendshipRequest.create(sender: buzzn_team[Random.rand(buzzn_team.size)], receiver: user)
  FriendshipRequest.create(sender: buzzn_team[Random.rand(buzzn_team.size)], receiver: user)
  puts "  #{user.email}"
end


puts '5 users without location'
5.times do
  user = Fabricate(:user)
  puts "  #{user.email}"
end

date            = Time.now
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
  puts "#{minute}: #{watt_hour}"
  #fake_readings << [(minute.utc.to_i*1000).to_s, watt_hour] # create time like discovergy
  fake_readings << [minute, watt_hour]
  minute += 1.minute
end


puts 'add smart meter readings'
buzzn_team.each do |user|
  Location.with_role(:manager, user).each do |location|
    location.metering_points.each do |metering_point|
      fake_readings.each do |fake_reading|
        Reading.create(
          register_id:  metering_point.register.id,
          timestamp:    fake_reading.first, #DateTime.strptime(fake_reading.first,'%Q'),
          watt_hour:    fake_reading.last
        )
      end
    end
  end
end


