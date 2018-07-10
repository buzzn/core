require_relative 'owner_base'
require_relative '../../../schemas/transactions/organization/update'

module Transactions::Admin::Localpool
  class UpdateOrganizationOwner < OwnerBase

    validate :schema
    authorize :allowed_roles
    around :db_transaction
    tee :create_or_update_address, with: :'operations.action.create_or_update_address'
    tee :create_or_update_contact_address, with: :'operations.action.create_or_update_address'
    tee :create_or_update_contact, with: :'operations.action.create_or_update_person'
    tee :create_or_update_legal_representation, with: :'operations.action.create_or_update_person'
    map :update_organization, with: :'operations.action.update'

    def schema(resource:, **)
      Schemas::Transactions::Organization.update_for(resource)
    end

    def allowed_roles(permission_context:)
      permission_context.update
    end

    def create_or_update_contact_address(params:, resource:)
      super(params: params[:contact] || {}, resource: resource.contact)
    end

    def create_or_update_contact(params:, resource:)
      super(params: params, method: :contact, resource: resource)
    end

    def create_or_update_legal_representation(params:, resource:)
      super(params: params, method: :legal_representation, resource: resource)
    end

  end
end
