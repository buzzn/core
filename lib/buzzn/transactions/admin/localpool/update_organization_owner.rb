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

    add :clear_legal_representation
    tee :create_or_update_legal_representation_address_stage1, with: :'operations.action.create_or_update_address'
    add :create_or_update_legal_representation_address_stage2, with: :'operations.action.create_or_update_address'
    tee :create_or_update_legal_representation, with: :'operations.action.create_or_update_person'

    map :update_organization, with: :'operations.action.update'

    def schema(resource:, **)
      Schemas::Transactions::Organization.update_for(resource)
    end

    def schema_second_pass(resource:, params:)
      schema_second_pass_validations = {}
      [[:contact, resource.object.contact], [:legal_representation, resource.object.legal_representation]].each do |nested|
        if !params[nested[0]].nil?
          if !params[nested[0]][:id].nil?
            # ID indicates an assignment
            schema = Schemas::Transactions::Person::Assign
          elsif !nested[1].nil? && !params[nested[0]][:updated_at].nil?
            # updated_at indicates an update, resource.object.nested must be set for this
            if nested[1].address.nil?
              schema = Schemas::Transactions::Person.update_without_address
            else
              schema = Schemas::Transactions::Person.update_with_address
            end
          else
            schema = Schemas::Transactions::Person::CreateWithAddress
          end

          result = schema.call(params[nested[0]])
          if result.success?
            Success(params[nested[0]].merge(params: result.output))
          else
            schema_second_pass_validations[nested[0]] = result.errors
          end

        end
      end

      if schema_second_pass_validations.size.positive?
        raise Buzzn::ValidationError.new(schema_second_pass_validations)
      end
    end

    def allowed_roles(permission_context:)
      permission_context.update
    end

    # clear methods:
    #
    # the owner already has a contact and the
    # contact provided in the params needs to be
    # created as it has no updated_at

    def clear_contact(params:, resource:)
      !resource.object.contact.nil? &&
        !params[:contact].nil? &&
        params[:contact][:updated_at].nil? &&
        params[:contact][:id].nil?
    end

    def clear_legal_representation(params:, resource:, **)
      !resource.object.legal_representation.nil? &&
        !params[:legal_representation].nil? &&
        params[:legal_representation][:updated_at].nil? &&
        params[:legal_representation][:id].nil?
    end

    def create_or_update_contact_address_stage1(params:, resource:, clear_contact:, **)
      unless clear_contact
        super(params: params[:contact] || {}, resource: resource.contact)
      end
    end

    def create_or_update_contact_address_stage2(params:, resource:, clear_contact:, **)
      if clear_contact
        super(params: params[:contact] || {}, resource: nil)
      end
    end

    def create_or_update_contact(params:, resource:, clear_contact:, create_or_update_contact_address_stage2:, **)
      super(params: params, method: :contact, force_new: clear_contact, resource: resource)
      if clear_contact
        params[:contact].address = create_or_update_contact_address_stage2
        params[:contact].save
      end
    end

    def create_or_update_legal_representation_address_stage1(params:, resource:, clear_legal_representation:, **)
      unless clear_legal_representation
        super(params: params[:legal_representation] || {}, resource: resource.legal_representation)
      end
    end

    def create_or_update_legal_representation_address_stage2(params:, resource:, clear_legal_representation:, **)
      if clear_legal_representation
        super(params: params[:legal_representation] || {}, resource: nil)
      end
    end

    def create_or_update_legal_representation(params:, resource:, clear_legal_representation:, create_or_update_legal_representation_address_stage2:, **)
      super(params: params, method: :legal_representation, force_new: clear_legal_representation, resource: resource)
      if clear_legal_representation
        params[:legal_representation].address = create_or_update_legal_representation_address_stage2
        params[:legal_representation].save
      end
    end

  end
end
