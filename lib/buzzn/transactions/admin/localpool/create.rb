require_relative '../localpool'
require_relative '../../../schemas/transactions/admin/localpool/create'

class Transactions::Admin::Localpool::Create < Transactions::Base
  def self.create(localpools)
    new.with_step_args(
      validate: [Schemas::Transactions::Admin::Localpool::Create],
      authorize: [localpools],
      persist: [localpools]
    )
  end

  step :validate, with: :'operations.validation'
  step :authorize, with: :'operations.authorization.create'
  step :persist

  def persist(input, localpools)
    Right(localpools.instance_class.create(localpools.current_user, input))
  end
end
