require_relative 'base'

class Transactions::Ticker < Transactions::Base

  step :authorize
  step :ticker, with: :'operations.ticker'

  def authorize(register)
    # TODO check privacy settings here
    Right(register)
  end
end
