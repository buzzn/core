require_relative '../document'
require_relative '../../delete'

class Transactions::Admin::Document::Delete < Transactions::Base

  check :authorize, with: :'operations.authorization.delete'
  map :delete_document, with: 'operations.action.delete'

end
