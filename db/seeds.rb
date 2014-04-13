# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
require 'rubygems' #so it can load gems

puts '-- seed development database --'

admin = Fabricate(:admin)
admin.add_role 'admin'

# puts 'create smart meter '
# puts '  justus'
# smart_meters << meter_justus = Fabricate(:meter_justus)
# justus = Fabricate(:justus)
# justus.add_role :manager, meter_justus


puts 'static meters for:'
%w[ felix danusch thomas martina stefan ole philipp christian ].each do |user_name|
  puts "  #{user_name}"
  user          = Fabricate(user_name)
  user_location = Fabricate(:location_muehlenkamp)
  user.add_role :manager, user_location
end


puts 'add smart meter readings'
User.all.each do |user|
  i=1
  Location.with_role(:manager, user).each do |location|
    location.metering_points.each do |metering_point|
      File.foreach("#{Rails.root}/db/seeds/meter#{i}.txt").with_index { |line, line_num|
        Reading.create(
          meter_id:  metering_point.meter.id,
          timestamp: DateTime.now.beginning_of_day + line_num.minute,
          wh:        line.to_i
        )
      }
      i+1
    end
  end
end

