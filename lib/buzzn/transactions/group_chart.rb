require_relative 'base'
require_relative '../schemas/transactions/chart'

class Transactions::GroupChart < Transactions::Base
  def self.for(localpool)
    super(Schemas::Transactions::Chart, localpool, :authorize, :chart)
  end

  step :validate, with: :'operations.validation'
  step :authorize, with: :'operations.authorization.generic'
  step :chart, with: :'operations.group_chart'

  def authorize(input, localpool)
    # TODO check privacy settings here
    Right(input)
  end
end
