require_relative 'assign_owner_base'

module Transactions::Admin::Localpool
  class AssignOwner < AssignOwnerBase
    def self.for(localpool)
      new.with_step_args(
        authorize: [localpool, :assign],
        persist: [localpool]
      )
    end

    step :authorize, with: :'operations.authorize.generic'
    step :persist

    def persist(input, localpool)
      Group::Localpool.transaction do
        Right(assign_owner(new_owner))
      end
    end
  end
end
