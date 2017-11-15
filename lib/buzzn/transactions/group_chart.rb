require_relative 'base'
require_relative '../schemas/transactions/chart'

class Transactions::GroupChart < Transactions::Base
  def self.for(group)
    super(Schemas::Transactions::Chart, group, :authorize, :chart)
  end

  step :validate, with: :'operations.validation'
  step :authorize
  step :chart, with: :'operations.group_chart'

  def authorize(input, group)
    # TODO needs to distinguish between admin and display
    # TODO check privacy settings here
    Right(input)
  end
end
