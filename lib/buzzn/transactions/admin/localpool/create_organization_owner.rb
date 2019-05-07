require_relative 'owner_base'
require_relative 'create_organization_base'

module Transactions::Admin::Localpool
  class CreateOrganizationOwner < OwnerBase

    include CreateOrganizationBase

    validate :schema
    authorize :allowed_roles
    around :db_transaction
    tee :create_address, with: :'operations.action.create_address'
    tee :create_contact_address, with: :'operations.action.create_address'
    tee :create_contact, with: :'operations.action.create_person'
    tee :create_legal_representation_address, with: :'operations.action.create_address'
    tee :create_legal_representation, with: :'operations.action.create_person'
    add :new_organization, with: :'operations.action.create_item'
    map :assign_owner # from super-class

    def allowed_roles(permission_context:)
      permission_context.owner.create
    end

    def assign_owner(new_organization:, resource:, **)
      super(new_owner: new_organization, resource: resource)
    end

  end
end
