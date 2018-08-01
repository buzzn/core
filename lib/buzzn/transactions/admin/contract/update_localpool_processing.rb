require_relative '../contract'
require_relative '../../../schemas/transactions/admin/contract/localpool_processing/update'

class Transactions::Admin::Contract::UpdateLocalpoolProcessing < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update'
  around :db_transaction
  map :update_localpool_processing_contract, with: :'operations.action.update'

  def schema
    Schemas::Transactions::Admin::Contract::LocalpoolProcessing::Update
  end

end
