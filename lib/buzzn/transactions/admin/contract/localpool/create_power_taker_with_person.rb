require_relative './create_power_taker_base'

module Transactions::Admin::Contract::Localpool
  class CreatePowerTakerWithPerson < CreatePowerTakerBase

    validate :schema
    check :authorize, with: :'operations.authorization.create'
    tee :localpool_schema
    tee :register_meta_schema
    around :db_transaction

    add :create_address, with: :'operations.action.create_address'
    add :create_customer, with: :'operations.action.create_person'

    tee :assign_contractor
    tee :assign_register_meta
    tee :create_register_meta_options
    map :create_contract, with: :'operations.action.create_item'

    def schema
      Schemas::Transactions::Admin::Contract::Localpool::PowerTaker::CreateWithPerson
    end

    def create_address(params:, **)
      super(params: params[:customer], resource: nil)
    end

    def create_customer(params:, **)
      super(params: params, resource: nil, method: :customer)
    end

  end
end
