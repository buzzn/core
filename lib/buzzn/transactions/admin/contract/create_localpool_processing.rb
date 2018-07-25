require_relative '../contract'
require_relative '../../../schemas/pre_conditions/contract/localpool_processing_contract.rb'

class Transactions::Admin::Contract::CreateLocalpoolProcessing < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.create'
  tee :localpool_schema
  around :db_transaction
  tee :assign_contractor
  tee :assign_customer
  tee :create_nested
  map :create_contract, with: :'operations.action.create_item'

  def schema
    Schemas::Transactions::Admin::Contract::LocalpoolProcessing::Create
  end

  def localpool_schema(localpool:, **)
    result = Schemas::PreConditions::Contract::LocalpoolProcessingContractCreate.call(localpool)
    unless result.success?
      raise Buzzn::ValidationError.new(result.errors)
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
    params[:tax_data] = Contract::TaxData.new(tax_number: params[:tax_number])
    params.delete(:tax_number)
  end

  def create_contract(params:, resource:, **)
    Contract::LocalpoolProcessingResource.new(
      *super(resource, params)
    )
  end

end
