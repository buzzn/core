module Transactions::Admin::Localpool
  class CreatePersonOwner

    validate :params_schema
    authorize :allowed_roles
    precondition :localpool_schema
    add :new_metering_point_operator_contract, with :'operations.action.new'
    add :generate_pdf
    around :db_transaction
    tee :store_pdf
    map :save_metering_point_operator_contract

    def params_schema
      Schemas::Transactions::Admin::Person::Create
    end

    def allowed_roles(permission_context:)
      permission_context.metering_point_operator_contract.create
    end

    def localpool_schema
      Schemas::PreConditions::Contract::MeteringPointOperatorCreate
    end

    def new_metering_point_operator_contract(params:, resource:)
      attrs = params.merge(localpool: resource.object)
      { object: super(Contract::MeteringPointOperator, attrs) }
    end

    def generate_pdf(object:)
      generator = Pdf::MeteringPointOperator.new(object)
      kw = { generator: generator }
      unless generator.pdf_document_stale?
        kw[:pdf] = generator.to_pdf
      end
      kw
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
