require_relative '../reading'
require_relative '../../../schemas/transactions/admin/reading/create'

class Transactions::Admin::Reading::Create < Transactions::Base

  def self.for(register)
    new.with_step_args(
      authorize: [register, *register.permissions.readings.create],
      persist: [register.readings]
    )
  end

  validate :schema
  step :authorize, with: :'operations.authorization.generic'
  map :persist

  def schema
    Schemas::Transactions::Admin::Reading::Create
  end

  def persist(input, readings)
    ReadingResource.new(readings.objects.create!(input), readings.context)
  end

end
