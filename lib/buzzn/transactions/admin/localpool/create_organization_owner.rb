require_relative 'owner_base'

module Transactions::Admin::Localpool
  class CreateOrganizationOwner < OwnerBase

    validate :schema
    authorize :allowed_roles
    around :db_transaction
    tee :create_address, with: :'operations.action.create_address'
    add :new_owner, with: :'operations.action.create_item'
    map :assign_owner # from super-class

    def schema
      Schemas::Transactions::Admin::Organization::Create
    end

    def allowed_roles(permission_context:)
      permission_context.owner.create
    end

    def new_owner(params:, resource:)
      attrs = params.merge(mode: :other) # FIXME remove this other mode
                                         # and mkae proper subclasses
      OrganizationResource.new(
        *super(resource.organizations, attrs)
      )
    end

  end
end
