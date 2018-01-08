require_relative '../operations'

class Operations::DailyCharts
  include Dry::Transaction::Operation
  include Import['services.charts']

  def call(group)
    Right(charts.daily(group.object))
  end
end
