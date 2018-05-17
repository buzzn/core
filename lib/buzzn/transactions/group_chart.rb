require_relative 'base'
require_relative '../schemas/transactions/chart'

class Transactions::GroupChart < Transactions::Base

  def self.for(group)
    super(group, :authorize, :chart)
  end

  validate :schema
  step :authorize
  step :chart, with: :'operations.group_chart'

  def authorize(input, group)
    # TODO needs to distinguish between admin and display
    # TODO check privacy settings here
    Success(input)
  end

  def schema
    Schemas::Transactions::Chart
  end

end
