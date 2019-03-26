require_relative 'update_base'
require_relative '../../../../schemas/transactions/admin/contract/localpool_processing/update'

module Transactions::Admin::Contract::Localpool
  class UpdateProcessing < UpdateBase

    validate :schema
    check :authorize, with: :'operations.authorization.update'
    tee :set_end_date, with: :'operations.end_date'
    around :db_transaction
    tee :update_tax_data
    map :update_localpool_processing_contract, with: :'operations.action.update'

    def schema
      Schemas::Transactions::Admin::Contract::Localpool::Processing::Update
    end

  end
end
