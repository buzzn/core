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
    authorize :allowed_roles
    around :db_transaction
    map :create_person, with: :'operations.action.create_item'
    map :assign_owner

    def schema
      Schemas::Transactions::Admin::Person::Create
    end

    def allowed_roles(permission_context:)
      permission_context.owner.create
    end

    def create_person(params:, resource:)
      PersonResource.new(
        *super(resource.persons, params)
      )
    end

  end
end
