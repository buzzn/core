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

puts 'create justus'
meters << meter_justus = Fabricate(:meter_justus)
jan = Fabricate(:justus)
jan.add_role :manager, meter_justus

puts 'create stefan'
meters << meter_stefan = Fabricate(:meter)
stefan = Fabricate(:stefan)
stefan.add_role :manager, meter_stefan

puts 'create jan'
meters << meter_jan = Fabricate(:meter)
jan = Fabricate(:jan)
jan.add_role :manager, meter_jan

puts 'create meter data'
meters.each do |meter|
  File.foreach("#{Rails.root}/db/seeds/meter#{meter.id}.txt").with_index { |line, line_num|
    Reading.create(
      meter_id:  meter.id,
      timestamp: DateTime.now.beginning_of_day + line_num.minute,
      wh:        line.to_i
    )
  }
end