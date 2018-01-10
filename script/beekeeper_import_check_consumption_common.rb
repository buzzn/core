# ActiveRecord::Base.logger = Logger.new(STDOUT)
require_relative "../lib/beekeeper/init"

def inspect_register(register)
  "#{register.name} (id: #{register.id})"
end

Group::Base.all.order(:name, :start_date).each do |group|

  puts
  puts "#{group.name} (start: #{group.start_date})"
  puts "-" * 80

registers = group.registers.consumption_common
  registers.each { |r| puts inspect_register(r) }
end
