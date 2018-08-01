require_relative 'localpool_resource'

module Contract
  class LocalpoolThirdPartyResource < LocalpoolResource

    model LocalpoolThirdParty

    has_one :market_location, Register::MetaResource do |object|
      object.register_meta
    end

  end
end
