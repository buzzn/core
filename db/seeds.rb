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


admin = Fabricate(:admin)
admin.add_role 'admin'


puts '  justus'
justus = Fabricate(:justus)
location_fichtenweg = Fabricate(:location_fichtenweg)
justus.add_role :manager, location_fichtenweg


puts 'static meters for:'
%w[ felix danusch thomas martina stefan ole philipp christian ].each do |user_name|
  puts "  #{user_name}"
  user          = Fabricate(user_name)
  user_location = Fabricate(:location_muehlenkamp)
  user.add_role :manager, user_location
end


puts '  20 more users'
20.times do
  location                = Fabricate(:location)
  contracting_party       = Fabricate(:contracting_party)
  user                    = Fabricate(:user)
  user.contracting_party  = contracting_party
  contracting_party.contracts << location.metering_points.first.contract
  user.add_role :manager, location
end



# puts 'add smart meter readings'
# User.all.each do |user|
#   i=1
#   Location.with_role(:manager, user).each do |location|
#     location.metering_points.each do |metering_point|
#       File.foreach("#{Rails.root}/db/seeds/meter#{i}.txt").with_index { |line, line_num|
#         Reading.create(
#           meter_id:  metering_point.meter.id,
#           timestamp: DateTime.now.beginning_of_day + line_num.minute,
#           wh:        line.to_i
#         )
#       }
#       i+1
#     end
#   end
# end

