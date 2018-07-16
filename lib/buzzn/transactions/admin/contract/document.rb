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
    # don't change order
    {
      stale: generator.pdf_document_stale?,
      pdf_document: generator.create_pdf_document
    }
  end

  def contract_document(resource:, params:, generator:, generate_document:)
    if ContractDocument.where(:contract_id => resource.id,
                              :document_id => generate_document[:pdf_document].document.id).any?
      ContractDocument.where(:contract_id => resource.id,
                             :document_id => generate_document[:pdf_document].document.id).first
    else
      ContractDocument.create!(contract_id: resource.id,
                               document_id: generate_document[:pdf_document].document.id)
    end
  end

  def result(resource:, params:, generator:, generate_document:, contract_document:)
    {
      stale: generate_document[:stale],
      document: contract_document
    }
  end

end
