require_relative 'base'

class Transactions::GroupChart < Transactions::Base
  def self.create(localpool)
    new.with_step_args(
      validate: Schemas::Transactions::Chart,
      authorize: [localpool],
      chart: [localpool]
    )
  end

  step :validate, with: :'operations.validation'
  step :authorize, with: :'operations.authorization.generic'
  step :chart, with: :'operations.group_chart'

  def authorize(input, localpool)
    # TODO check privacy settings here
    Right(input)
  end
end
