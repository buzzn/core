require_relative '../localpool'
require_relative '../../../schemas/transactions/admin/localpool/update'

class Transactions::Admin::Localpool::Update < Transactions::Base
  def self.create(localpool)
    new.with_step_args(
      validate: [Schemas::Transactions::Admin::Localpool::Update],
      authorize: [localpool],
      persist: [localpool]
    )
  end

  step :validate, with: :'operations.validation'
  step :authorize, with: :'operations.authorization.update'
  step :persist, with: :'operations.action.update'
end
