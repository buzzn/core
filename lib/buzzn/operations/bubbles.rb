require_relative '../operations'

class Operations::Bubbles

  include Dry::Transaction::Operation
  include Import['services.current_power']

  def call(group)
    Right(current_power.bubbles(group.object))
  end

end
