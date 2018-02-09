require_relative '../operations'

class Operations::Chart

  include Dry::Transaction::Operation
  include Import['services.charts']

  def interval(input)
    Buzzn::Interval.create(input[:duration], input[:timestamp])
  end

end
