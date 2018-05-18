require_relative 'base'

class Transactions::Delete < Transactions::Base

  check :authorize, with: :'operations.authorization.delete'
  map :delete, with: :'operations.action.delete'

end
