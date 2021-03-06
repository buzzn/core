require_relative '../market_function'
require_relative '../../delete'
require_relative 'base'

module Transactions::Admin::MarketFunction
  class Delete < Base

    check :authorize, with: :'operations.authorization.delete'
    tee :check_relation
    map :delete, with: :'operations.action.delete'

  end
end
