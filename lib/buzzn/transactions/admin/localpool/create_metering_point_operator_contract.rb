module Transactions::Admin::Localpool
  class CreateMeteringPointOperatorContract

    validate :params_schema
    authorize :allowed_roles
    precondition :localpool_schema
    add :object, with: :'operations.action.new'
    add :generator
    add :pdf
    around :db_transaction
    tee :store_pdf
    map :save_metering_point_operator_contract

    def params_schema
      Schemas::Transactions::Admin::Contract::MeteringPointOperator::Create
    end

    def allowed_roles(permission_context:)
      permission_context.metering_point_operator_contract.create
    end

    def localpool_schema
      Schemas::PreConditions::Contract::MeteringPointOperatorCreate
    end

    def new_metering_point_operator_contract(params:, resource:)
      attrs = params.merge(localpool: resource.object)
      super(Contract::MeteringPointOperator, attrs)
    end
    alias object new_metering_point_operator_contract

    def generator(object:)
      Pdf::MeteringPointOperator.new(object)
    end

    def pdf(generator:)
      generator.to_pdf if generator.pdf_document_stale?
    end

    def store_pdf(generator:, pdf:, object:)
      pdf_document = generator.create_pdf_document(pdf)
      object.pdf_documents << pdf_document
    end

    def save_metering_point_operator_contract(object:, resource:)
      object.save!
      Contract::MeteringPointOperatorResource.new(object, resource.security_context.metering_point_operator_contract)
    end
  end
end
