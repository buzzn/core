require 'clockwork'
require './config/boot'
require './config/environment'
module Clockwork
  handler do |job|
    puts "Running #{job}"
  end
  every(1.day, 'group.calculate_scores', :at => '04:30') { Group::Base.calculate_scores }
  every(5.minutes, 'register.observe') { Register::Base.observe }
end
