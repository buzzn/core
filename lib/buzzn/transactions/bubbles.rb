require_relative 'base'

class Transactions::Bubbles < Transactions::Base

  step :authorize
  step :bubbles, with: :'operations.bubbles'

  def authorize(group)
    # TODO check privacy settings here
    Right(group)
  end
end
