require_relative 'base'

class Transactions::Ticker < Transactions::Base

  step :authorize
  map :ticker, with: :'operations.ticker'

  def authorize(register)
    # TODO check privacy settings here
    Success(register)
  end

end
