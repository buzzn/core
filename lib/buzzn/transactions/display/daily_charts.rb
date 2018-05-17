require_relative '../display'

class Transactions::Display::DailyCharts < Transactions::Base

  step :authorize
  map :daily_charts, with: :'operations.daily_charts'

  def authorize(group)
    # TODO check privacy settings here
    Success(group)
  end

end
