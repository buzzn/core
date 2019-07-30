#
# run with:
# bundle exec ruby script/discovergy_api.rb
#

require ::File.expand_path('../../config/buzzn', __FILE__)
require 'awesome_print'

group = Group::Base.find_by(slug: 'heigelstrasse')
date  = Date.today.beginning_of_day
ap Services::Datasource::Discovergy::SingleReading.new.all(group, date)
