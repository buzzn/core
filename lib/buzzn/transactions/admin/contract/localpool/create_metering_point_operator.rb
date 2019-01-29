require_relative '../localpool'
require_relative '../../../../schemas/pre_conditions/localpool/create_metering_point_operator_contract'

class Transactions::Admin::Contract::Localpool::CreateMeteringPointOperator < Transactions::Base

  validate :schema
  check :authorize, with: 'operations.authorization.create'
  tee :localpool_schema
  tee :set_end_date, with: :'operations.end_date'
  around :db_transaction
  tee :assign_contractor
  tee :assign_customer
  map :create_contract, with: :'operations.action.create_item'

  def schema
    Schemas::Transactions::Admin::Contract::Localpool::MeteringPointOperator::Create
  end

  def localpool_schema(localpool:, **)
    subject = Schemas::Support::ActiveRecordValidator.new(localpool.object)
    result = Schemas::PreConditions::Localpool::CreateMeteringPointOperatorContract.call(subject)
    unless result.success?
      raise Buzzn::ValidationError.new('localpool': result.errors)
    end
  end

  def assign_contractor(params:, **)
    params[:contractor] = Organization::Market.buzzn
  end

  def assign_customer(params:, resource:, localpool:)
    params[:customer] = localpool.owner.object
  end

  def create_contract(params:, resource:, **)
    Contract::MeteringPointOperatorResource.new(
      *super(resource, params)
    )
  end

end
