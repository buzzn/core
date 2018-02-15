require_relative 'localpool_resource'

module Contract
  class LocalpoolThirdPartyResource < LocalpoolResource

    model LocalpoolThirdParty

    has_one :market_location

  end
end
