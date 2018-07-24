require_relative '../contract'

class Transactions::Admin::Contract::CreateLocalpoolProcessing < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.create'
  around :db_transaction
  tee :assign_contractor
  tee :assign_customer
  tee :create_nested
  map :create_contract, with: :'operations.action.create_item'

  def schema
    Schemas::Transactions::Admin::Contract::LocalpoolProcessing::Create
  end

  def assign_contractor(params:, **)
    # TODO move to Group
    params[:contractor] = Organization::Market.buzzn
  end

  def assign_customer(params:, resource:)
    localpool = resource.objects.proxy_association.owner
    params[:customer] = localpool.owner
  end

  def create_nested(params:, resource:)
    params[:tax_data] = Contract::TaxData.new(tax_number: params[:tax_number])
    params.delete(:tax_number)
  end

  def create_contract(params:, resource:)
    Contract::LocalpoolProcessingResource.new(
      *super(resource, params)
    )
  end

end
