require_relative '../reading'
require_relative '../../delete'

class Transactions::Admin::Reading::Delete < Transactions::Base

  check :authorize, with: :'operations.authorization.delete'
  precondition :schema
  map :delete, with: :'operations.action.delete'

  def schema
    Schemas::PreConditions::Reading::Delete
  end

end
