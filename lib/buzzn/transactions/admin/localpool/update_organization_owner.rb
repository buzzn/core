require_relative 'owner_base'
require_relative '../../../schemas/transactions/organization/update'
require_relative '../../../schemas/transactions/person/create'
require_relative '../../../schemas/transactions/address'
require_relative '../../step_adapters/validate'


module Transactions::Admin::Localpool
  class UpdateOrganizationOwner < OwnerBase

    validate :schema
    tee :schema_second_pass
    authorize :allowed_roles
    around :db_transaction
    tee :create_or_update_address, with: :'operations.action.create_or_update_address'
    add :clear_contact
    tee :create_or_update_contact_address_stage1, with: :'operations.action.create_or_update_address'
    add :create_or_update_contact_address_stage2, with: :'operations.action.create_or_update_address'
    tee :create_or_update_contact, with: :'operations.action.create_or_update_person'
    tee :create_or_update_legal_representation, with: :'operations.action.create_or_update_person'
    map :update_organization, with: :'operations.action.update'

    def schema(resource:, **)
      Schemas::Transactions::Organization.update_for(resource)
    end

    def schema_second_pass(resource:, params:)
      if !params[:contact].nil?
        if !params[:contact][:id].nil?
          # ID indicates an assignment
          schema = Schemas::Transactions::Person::Assign
        elsif !resource.object.contact.nil? && !params[:contact][:updated_at].nil?
          # updated_at indicates an update, resource.object.contact must be set for this
          if resource.object.contact.address.nil?
            schema = Schemas::Transactions::Person.update_without_address
          else
            schema = Schemas::Transactions::Person.update_with_address
          end
        else
          schema = Schemas::Transactions::Person::CreateWithAddress
        end

        # non-DRY :/
        result = schema.call(params[:contact])
        if result.success?
          Success(params[:contact].merge(params: result.output))
        else
          raise Buzzn::ValidationError.new(result.errors)
        end

      end
    end

    def allowed_roles(permission_context:)
      permission_context.update
    end

    def clear_contact(params:, resource:)
      # the owner already has a contact and the
      # contact provided in the params needs to be
      # created as it has no updated_at
      !resource.object.contact.nil? && !params[:contact].nil? && params[:contact][:updated_at].nil?
    end

    def create_or_update_contact_address_stage1(params:, resource:, clear_contact:)
      unless clear_contact
        super(params: params[:contact] || {}, resource: resource.contact)
      end
    end

    def create_or_update_contact_address_stage2(params:, resource:, clear_contact:)
      if clear_contact
        super(params: params[:contact] || {}, resource: nil)
      end
    end

    def create_or_update_contact(params:, resource:, clear_contact:, create_or_update_contact_address_stage2:)
      super(params: params, method: :contact, force_new: clear_contact, resource: resource)
      if clear_contact
        params[:contact].address = create_or_update_contact_address_stage2
        params[:contact].save
      end
    end

    def create_or_update_legal_representation(params:, resource:, **)
      super(params: params, method: :legal_representation, resource: resource)
    end

  end
end
