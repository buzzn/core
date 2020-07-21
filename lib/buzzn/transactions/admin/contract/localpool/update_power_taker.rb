require_relative 'update_base'
require_relative '../../../../schemas/transactions/admin/contract/localpool_power_taker/update'

module Transactions::Admin::Contract::Localpool
  class UpdatePowerTaker < UpdateBase

    validate :schema
    check :authorize, with: :'operations.authorization.update'
    check :overlappings, with: :'operations.overlappings'
    tee :set_end_date, with: :'operations.end_date'
    around :db_transaction
    tee :update_register_meta, with: :'operations.action.update'
    tee :update_register_meta_options
    tee :update_tax_data
    map :update_localpool_power_taker_contract, with: :'operations.action.update'

    def schema
      Schemas::Transactions::Admin::Contract::Localpool::PowerTaker::Update
    end

  end
end
