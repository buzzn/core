require_relative 'base'
require_relative '../schemas/transactions/chart'

class Transactions::RegisterChart < Transactions::Base
  def self.for(register)
    super(Schemas::Transactions::Chart, register, :authorize, :chart)
  end

  step :validate, with: :'operations.validation'
  step :authorize
  step :chart, with: :'operations.register_chart'

  def authorize(input, register)
    # TODO needs to distinguish between admin and display
    # TODO check privacy settings here
    Right(input)
  end
end
