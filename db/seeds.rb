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
    user_location = Fabricate(:location_fichtenweg)
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

puts '20 more users'
20.times do
  location                    = Fabricate(:location)
  contracting_party           = Fabricate(:contracting_party)
  user                        = Fabricate(:user)
  user.contracting_party      = contracting_party
  metering_point              = location.metering_points.first
  metering_point.users        << user
  contracting_party.contracts << metering_point.contract
  user.add_role :manager, location
end



puts 'add smart meter readings'
buzzn_team.each do |user|
  i=1
  Location.with_role(:manager, user).each do |location|
    location.metering_points.each do |metering_point|
      metering_point.meter.registers.each do |register|
        File.foreach("#{Rails.root}/db/seeds/meter#{i}.txt").with_index { |line, line_num|
          Reading.create(
            register_id:  register.id,
            timestamp:    DateTime.now.beginning_of_day + line_num.minute,
            watt_hour:    line.to_i
          )
        }
        i+1
      end
    end
  end
end

