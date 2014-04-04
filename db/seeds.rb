# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
require 'rubygems' #so it can load gems

puts '-- seed development database --'

meters = []
smart_meters = []

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
  meters << meter_user = Fabricate(:meter)
  user = Fabricate(user_name)
  user.add_role :manager, meter_user
end


puts 'add smart meter readings'
smart_meters.each do |meter|
  File.foreach("#{Rails.root}/db/seeds/meter#{meter.id}.txt").with_index { |line, line_num|
    Reading.create(
      meter_id:  meter.id,
      timestamp: DateTime.now.beginning_of_day + line_num.minute,
      wh:        line.to_i
    )
  }
end