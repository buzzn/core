require_relative 'base'

class Transactions::Delete < Transactions::Base

  check :authorize, with: :'operations.authorization.delete'
  map :persist, with: :'operations.action.delete'

end
