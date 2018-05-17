require_relative 'owner_base'

module Transactions::Admin::Localpool
  class CreatePersonOwner < OwnerBase

    def self.for(localpool)
      new.with_step_args(
        authorize: [localpool, localpool.permissions.owner.create],
        create: [localpool],
        assign_owner: [localpool]
      )
    end

    validate :schema
    step :authorize, with: :'operations.authorize.generic'
    around :db_transaction
    map :create
    map :assign_owner

    def schema
      Schemas::Transactions::Admin::Organization::Create
    end

    def create(input, localpool)
      context = localpool.context.owner
      OrganizationResource.new(Organization.create!(input.merge(mode: :other), context))
    end

  end
end
