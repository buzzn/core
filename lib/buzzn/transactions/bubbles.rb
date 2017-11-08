require_relative 'base'

class Transactions::Bubbles < Transactions::Base
  def self.for(localpool)
    super(nil, localpool, :authorize, :bubbles)
  end

  step :authorize, with: :'operations.authorization.generic'
  step :bubbles, with: :'operations.bubbles'

  def authorize(input, localpool)
    # TODO check privacy settings here
    Right(input)
  end
end
