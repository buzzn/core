require_relative 'owner_base'

module Transactions::Admin::Localpool
  class CreatePersonOwner < OwnerBase

    validate :schema
    authorize :allowed_roles
    around :db_transaction
    tee :create_address, with: :'operations.action.create_address'
    map :create_person, with: :'operations.action.create_item'
    map :assign_owner

    def schema
      Schemas::Transactions::Person::Create
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
