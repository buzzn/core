require_relative '../localpool'
require_relative '../../../../schemas/pre_conditions/localpool/create_localpool_processing_contract'

class Transactions::Admin::Contract::Localpool::CreateProcessing < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.create'
  tee :localpool_schema
  tee :set_end_date, with: :'operations.end_date'
  around :db_transaction
  tee :assign_contractor
  tee :assign_customer
  tee :create_nested
  map :create_contract, with: :'operations.action.create_item'

  def schema
    Schemas::Transactions::Admin::Contract::Localpool::Processing::Create
  end

  def localpool_schema(localpool:, **)
    subject = Schemas::Support::ActiveRecordValidator.new(localpool.object)
    result = Schemas::PreConditions::Localpool::CreateLocalpoolProcessingContract.call(subject)
    unless result.success?
      raise Buzzn::ValidationError.new('localpool': result.errors)
    end
  end

  def assign_contractor(params:, **)
    # TODO move to Group
    params[:contractor] = Organization::Market.buzzn
  end

  def assign_customer(params:, resource:, localpool:)
    params[:customer] = localpool.owner.object
  end

  def create_nested(params:, resource:, **)
    params[:tax_data] = Contract::TaxData.new(tax_number: params.delete(:tax_number),
                                              sales_tax_number: params.delete(:sales_tax_number),
                                              creditor_identification: params.delete(:creditor_identification))
  end

  def create_contract(params:, resource:, **)
    Contract::LocalpoolProcessingResource.new(
      *super(resource, params)
    )
  end

end
