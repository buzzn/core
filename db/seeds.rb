# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
require 'rubygems' #so it can load gems

puts '  seed development database'

meters = []

puts 'create admin'
admin = Fabricate(:admin)
admin.add_role 'admin'

puts 'create stefan'
meters << meter_stefan = Fabricate(:meter_stefan)
stefan = Fabricate(:stefan)
stefan.add_role :manager, meter_stefan

puts 'create jan'
meters << meter_jan = Fabricate(:meter_jan)
jan = Fabricate(:jan)
jan.add_role :manager, meter_jan

puts 'chreate meter data'
meters.each do |meter|
  File.foreach("#{Rails.root}/db/seeds/meter#{meter.id}.txt").with_index { |line, line_num|
    Reading.create(
      meter_id:  meter.id,
      timestamp: DateTime.now.beginning_of_day + line_num.minute,
      wh:        line.to_i
    )
  }
end