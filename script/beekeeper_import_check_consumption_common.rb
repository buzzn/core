# ActiveRecord::Base.logger = Logger.new(STDOUT)
require_relative "../lib/beekeeper/init"

def inspect_register(register)
  "#{register.name} (id: #{register.id})"
end

num_registers            = 0
groups_without_registers = []

relevant_groups = Group::Base.where("start_date <= ?", Date.today).where.not("name LIKE 'Localpool%'").order(:name, :start_date)

relevant_groups.each do |group|

  puts
  puts "#{group.name} (start: #{group.start_date})"
  puts "-" * 80

  registers = group.registers.consumption_common
  num_registers += registers.size
  groups_without_registers << group if registers.empty?

  registers.each { |r| puts inspect_register(r) }
end

puts
puts "Total of #{num_registers} common registers."
puts "#{groups_without_registers.size} of #{relevant_groups.size} groups without common registers."
