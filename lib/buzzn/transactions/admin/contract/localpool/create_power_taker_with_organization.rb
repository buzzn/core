require_relative './create_power_taker_base'

module Transactions::Admin::Contract::Localpool
  class CreatePowerTakerWithOrganization < CreatePowerTakerBase

    validate :schema
    tee :schema_paranoid
    check :authorize, with: :'operations.authorization.create'
    tee :localpool_schema
    tee :register_meta_schema
    tee :set_end_date, with: :'operations.end_date'
    around :db_transaction

    tee :create_contact_address, with: :'operations.action.create_address'
    tee :create_contact, with: :'operations.action.create_person'

    tee :create_legal_representation_address, with: :'operations.action.create_address'
    tee :create_legal_representation, with: :'operations.action.create_person'

    tee :create_customer_address, with: :'operations.action.create_address'
    tee :create_customer_organization, with: :'operations.action.create_organization'

    tee :assign_contractor
    tee :assign_register_meta
    tee :create_register_meta_options
    tee :create_tax_data
    map :create_contract, with: :'operations.action.create_item'

    def schema
      Schemas::Transactions::Admin::Contract::Localpool::PowerTaker::CreateWithOrganization
    end

    def schema_paranoid(params:, **)
      validation_errors = {}
      validation_errors[:customer] = {}
      [:contact, :legal_representation].each do |nested|
        next if params[:customer][nested].nil?
        if params[:customer][nested][:id].nil?
          schema = Schemas::Transactions::Person::CreateWithAddress
        else
          schema = Schemas::Transactions::Person::Assign
        end
        result = schema.call(params[:customer][nested])
        if result.success?
          Success(params[:customer][nested].replace(result.output))
        else
          validation_errors[:customer][nested] = result.errors
        end
      end

      if validation_errors[:customer].size.positive?
        raise Buzzn::ValidationError.new(validation_errors)
      end
    end

    def create_contact_address(params:, resource:, **)
      super(params: params[:customer][:contact] || {})
    end

    def create_contact(params:, resource:, **)
      super(params: params[:customer], method: :contact)
    end

    def create_legal_representation_address(params:, resource:, **)
      super(params: params[:customer][:legal_representation] || {})
    end

    def create_legal_representation(params:, resource:, **)
      super(params: params[:customer], method: :legal_representation)
    end

    def create_customer_address(params:, resource:, **)
      super(params: params[:customer] || {})
    end

    def create_customer_organization(params:, resource:, **)
      super(params: params, method: :customer)
    end

  end
end
