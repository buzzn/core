#require_relative '../contract'
require_relative '../../../delete'

class Transactions::Admin::Contract::Localpool::DeleteGapContract < Transactions::Base

  check :authorize, with: :'operations.authorization.delete'
  precondition :schema
  map :delete_gap_contract, with: 'operations.action.delete'

  def schema
    Schemas::PreConditions::Contract::Delete
  end

end