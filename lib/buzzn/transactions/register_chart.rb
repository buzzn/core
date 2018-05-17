require_relative 'base'
require_relative '../schemas/transactions/chart'

class Transactions::RegisterChart < Transactions::Base

  def self.for(register)
    super(register, :authorize, :chart)
  end

  validate :schema
  step :authorize
  step :chart, with: :'operations.register_chart'

  def authorize(input, register)
    # TODO needs to distinguish between admin and display
    # TODO check privacy settings here
    Success(input)
  end

  def schema
    Schemas::Transactions::Chart
  end

end
