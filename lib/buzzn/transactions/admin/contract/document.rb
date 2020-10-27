require_relative '../contract'
require_relative '../../../schemas/pre_conditions/contract/document_localpool_processing_contract'
require_relative '../../../schemas/pre_conditions/contract/document_metering_point_operator_contract'

class Transactions::Admin::Contract::Document < Transactions::Base

  check :authorize, with: :'operations.authorization.document'
  validate :schema
  add :generator_names
  tee :check_generator_name
  add :generator
  tee :contract_schema
  around :db_transaction
  add :generate_document
  add :contract_document
  map :result

  def schema
    Schemas::Transactions::Admin::Contract::Document
  end

  def contract_schema(resource:, params:, generator:, **)
    subject = Schemas::Support::ActiveRecordValidator.new(resource.object)
    case resource
    when Contract::LocalpoolProcessingResource
      result = Schemas::PreConditions::Contract::DocumentLocalpoolProcessingContract.call(subject)
    when Contract::MeteringPointOperatorResource
      result = Schemas::PreConditions::Contract::DocumentMeteringPointOperatorContract.call(subject)
    when Contract::LocalpoolPowerTakerResource
      case generator
      when 'lsn_a1'
        result = Schemas::PreConditions::Contract::DocumentLocalpoolPowerTakerContractConfirmationA01.call(subject)
      when 'lsn_a2'
        result = Schemas::PreConditions::Contract::DocumentLocalpoolPowerTakerContractConfirmationA02.call(subject)
      end
    end
    unless result.nil?
      unless result.success?
        raise Buzzn::ValidationError.new(result.errors, resource.object)
      end
    end
  end

  def generator_names(resource:, params:)
    resource.object.pdf_generators.map { |g| [g.name.split("::").last.underscore, g] }.to_h
  end

  def check_generator_name(generator_names:, params:, **)
    unless generator_names.include?(params[:template])
      raise Buzzn::ValidationError.new({template: ['not a valid template']})
    end
  end

  def generator(generator_names:, params:, resource:)
    #  TODO replace by `Vat.current` there is a requirement to have here the previous,
    # vat in the timespan between July and Dezember 2020
    # Dont ask why.
    generator_names[params[:template]].new(resource.object, Vat.all[-2])
  end

  def generate_document(resource:, params:, generator:, **)
    generator.create_pdf_document
  end

  def contract_document(resource:, params:, generator:, generate_document:, **)
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
