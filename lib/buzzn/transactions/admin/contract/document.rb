require_relative '../contract'

class Transactions::Admin::Contract::Document < Transactions::Base

  check :authorize, with: :'operations.authorization.document'
  add :generator
  add :generate_document
  add :contract_document
  map :result

  def generator(resource:, params:)
    resource.pdf_generator.new(resource)
  end

  def generate_document(resource:, params:, generator:)
    generator.create_pdf_document
  end

  def contract_document(resource:, params:, generator:, generate_document:)
    doc = generate_document.document
    resource.object.documents << doc
    doc
  end

  def result(contract_document:, **)
    DocumentResource.new(contract_document)
  end

end
