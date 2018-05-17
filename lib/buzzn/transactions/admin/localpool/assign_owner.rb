require_relative 'owner_base'

module Transactions::Admin::Localpool
  class AssignOwner < OwnerBase

    def self.for(localpool)
      new.with_step_args(
        authorize: [localpool, *localpool.permissions.owner.update],
        persist: [localpool]
      )
    end

    step :authorize, with: :'operations.authorization.generic'
    around :db_transaction
    map :persist

    def persist(input, localpool)
      assign_owner(localpool, input)
    end

  end
end
