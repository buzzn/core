require_relative '../localpool'
require_relative 'create_power_taker_base'

module Transactions::Admin::Contract::Localpool
  class CreateGapContract < CreatePowerTakerBase

    validate :schema
    check :authorize, with: 'operations.authorization.create'
    tee :localpool_schema
    tee :register_meta_schema
    tee :set_end_date, with: :'operations.end_date'
    around :db_transaction
    tee :assign_customer
    tee :assign_contractor
    tee :assign_register_meta
    tee :create_register_meta_options
    map :create_gap_contract, with: :'operations.action.create_item'

    def schema
      Schemas::Transactions::Admin::Contract::Localpool::GapContract::Create
    end

    def localpool_schema(localpool:, **)
      subject = Schemas::Support::ActiveRecordValidator.new(localpool.object)
      result = Schemas::PreConditions::Localpool::CreateLocalpoolGapContract.call(subject)
      unless result.success?
        raise Buzzn::ValidationError.new('localpool': result.errors)
      end
    end

    def assign_customer(params:, localpool:, **)
      params[:customer] = localpool.gap_contract_customer.object
    end

    def create_gap_contract(params:, resource:, **)
      Contract::LocalpoolGapContractResource.new(
        *super(resource, params)
      )
    end

  end
end
