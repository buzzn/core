require_relative 'base'

class Transactions::Delete < Transactions::Base

  step :authorize, with: :'operations.authorization.delete'
  step :persist, with: :'operations.action.delete'

end
