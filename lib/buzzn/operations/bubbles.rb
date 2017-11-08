require_relative '../operations'

class Operations::Bubbles
  include Dry::Transaction::Operation
  include Import['service.current_power']

  def call(input, group)
    Right(current_power.for_each_register_in_group(group))
  end
end
