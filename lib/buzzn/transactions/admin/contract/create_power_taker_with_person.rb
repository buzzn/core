require_relative './create_power_taker_base'

module Transactions::Admin::Contract
  class CreatePowerTakerWithPerson < CreatePowerTakerBase

    validate :schema
    check :authorize, with: :'operations.authorization.create'
    around :db_transaction

    add :create_address, with: :'operations.action.create_address'
    add :create_customer, with: :'operations.action.create_person'

    tee :assign_contractor
    tee :assign_register_meta
    map :create_contract, with: :'operations.action.create_item'

    def schema
      Schemas::Transactions::Admin::Contract::PowerTaker::CreateWithPerson
    end

    def create_address(params:, **)
      super(params: params[:customer], resource: nil)
    end

    def create_customer(params:, **)
      super(params: params, resource: nil, method: :customer)
    end

  end
end
