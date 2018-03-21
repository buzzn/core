require_relative '../operations'

class Operations::DailyCharts

  include Dry::Transaction::Operation
  include Import['services.charts']

  def call(group)
    Success(charts.daily(group.object))
  end

end
