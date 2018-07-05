require_relative 'owner_base'
require_relative '../../../schemas/transactions/organization/create'

module Transactions::Admin::Localpool
  class CreateOrganizationOwner < OwnerBase

    validate :schema
    authorize :allowed_roles
    around :db_transaction
    tee :create_address, with: :'operations.action.create_address'
    tee :create_contact_address, with: :'operations.action.create_address'
    tee :create_contact, with: :'operations.action.create_person'
    tee :create_legal_representation, with: :'operations.action.create_person'
    add :new_owner, with: :'operations.action.create_item'
    map :assign_owner # from super-class

    def schema
      Schemas::Transactions::Organization::CreateWithNested
    end

    def allowed_roles(permission_context:)
      permission_context.owner.create
    end

    def create_contact_address(params:, resource:)
      super(params: params[:contact] || {})
    end

    def create_contact(params:, resource:)
      super(params: params, method: :contact)
    end

    def create_legal_representation(params:, resource:)
      super(params: params, method: :legal_representation)
    end

    def new_owner(params:, resource:)
      Organization::GeneralResource.new(
        *super(resource.organizations, params)
      )
    end

  end
end
