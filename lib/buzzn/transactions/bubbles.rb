require_relative 'base'

class Transactions::Bubbles < Transactions::Base

  step :authorize
  map :bubbles, with: :'operations.bubbles'

  def authorize(group)
    # TODO check privacy settings here
    Success(group)
  end

end
