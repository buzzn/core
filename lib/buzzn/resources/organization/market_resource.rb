require_relative 'base_resource'
require_relative 'market_function_resource'

module Organization
  class MarketResource < BaseResource

    model Organization::Market

    has_many :market_functions, MarketFunctionResource
    has_one :address, AddressResource

  end
end
