require_relative 'localpool_resource'

module Contract
  class LocalpoolThirdPartyResource < LocalpoolResource

    model LocalpoolThirdParty

    has_one :register

  end
end
