require_relative '../localpool'

class Transactions::Admin::Localpool::AssignOwner < Transactions::Base
  def self.for(localpool)
    new.with_step_args(
      authorize: [localpool, :assign],
      persist: [localpool]
    )
  end

  step :authorize, with: :'operations.authorize.generic'
  step :persist

  def persist(input, localpool)
    Right(localpool.object.update!(owner: input))
  end
end
