require_relative '../contract'
require_relative '../../../schemas/pre_conditions/contract/document_localpool_processing_contract'

class Transactions::Admin::Contract::Document < Transactions::Base

  check :authorize, with: :'operations.authorization.document'
  tee :contract_schema
  around :db_transaction
  add :generator
  add :generate_document
  add :contract_document
  map :result

  def contract_schema(resource:, **)
    case resource
    when Contract::LocalpoolProcessingResource
      subject = Schemas::Support::ActiveRecordValidator.new(resource.object)
      result = Schemas::PreConditions::Contract::DocumentLocalpoolProcessingContract.call(subject)
      unless result.success?
        raise Buzzn::ValidationError.new(result.errors)
      end
    end
  end

  def generator(resource:, params:)
    resource.pdf_generator.new(resource)
  end

  def generate_document(resource:, params:, generator:)
    generator.create_pdf_document
  end

  def contract_document(resource:, params:, generator:, generate_document:)
    doc = generate_document.document
    # check if it already exists
    unless resource.object.documents.where(:id => doc.id).any?
      resource.object.documents << doc
    end
    doc
  end

  def result(contract_document:, **)
    DocumentResource.new(contract_document)
  end

end
