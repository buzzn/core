require_relative 'update_base'
require_relative '../../../../schemas/transactions/admin/contract/localpool_third_party/update'

module Transactions::Admin::Contract::Localpool
  class UpdateThirdParty < UpdateBase

    validate :schema
    check :authorize, with: :'operations.authorization.update'
    tee :set_end_date, with: :'operations.end_date'
    around :db_transaction
    tee :update_register_meta, with: :'operations.action.update'
    tee :update_register_meta_options
    map :update_localpool_third_party_contract, with: :'operations.action.update'

    def schema
      Schemas::Transactions::Admin::Contract::Localpool::ThirdParty::Update
    end

  end
end
