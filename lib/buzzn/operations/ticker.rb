require_relative '../operations'

class Operations::Ticker

  include Dry::Transaction::Operation
  include Import['services.current_power']

  def call(register)
    current_power.ticker(register.object)
  end

end
