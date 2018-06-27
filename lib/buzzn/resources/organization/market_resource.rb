require_relative 'base_resource'

module Organization
  class MarketResource < BaseResource

    model Organization::Market

    has_many :market_functions

  end
end
