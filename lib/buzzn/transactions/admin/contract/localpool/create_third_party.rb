require_relative '../localpool'
require_relative '../../../../schemas/pre_conditions/localpool/create_localpool_third_party_contract'
require_relative 'create_power_taker_base'

# this is a reduced power taker contract, so derive from it for some methods
module Transactions::Admin::Contract::Localpool
  class CreateThirdParty < CreatePowerTakerBase

    validate :schema
    check :authorize, with: :'operations.authorization.create'
    tee :localpool_schema
    tee :register_meta_schema
    tee :set_end_date, with: :'operations.end_date'
    around :db_transaction
    tee :assign_register_meta
    tee :create_register_meta_options
    map :create_third_party_contract, with: :'operations.action.create_item'

    def schema
      Schemas::Transactions::Admin::Contract::Localpool::ThirdParty::Create
    end

    def localpool_schema(localpool:, **)
      subject = Schemas::Support::ActiveRecordValidator.new(localpool.object)
      result = Schemas::PreConditions::Localpool::CreateLocalpoolThirdPartyContract.call(subject)
      unless result.success?
        raise Buzzn::ValidationError.new(result.errors, localpool.object)
      end
    end

    def create_third_party_contract(params:, resource:, **)
      Contract::LocalpoolThirdPartyResource.new(
        *super(resource, params)
      )
    end

  end
end
