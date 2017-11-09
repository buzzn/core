require_relative '../reading'
require_relative '../../../schemas/transactions/admin/reading/create'

class Transactions::Admin::Reading::Create < Transactions::Base
  def self.for(register)
    new.with_step_args(
      validate: [Schemas::Transactions::Admin::Reading::Create],
      authorize: [register, *register.permissions.readings.create],
      persist: [register.readings]
    )
  end

  step :validate, with: :'operations.validation'
  step :authorize, with: :'operations.authorization.generic'
  step :persist

  def persist(input, readings)
    Right(ReadingResource.new(readings.objects.create!(input), readings.context))
  end
end
