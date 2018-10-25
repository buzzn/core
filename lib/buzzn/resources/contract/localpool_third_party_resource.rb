require_relative 'localpool_resource'
require_relative '../register/meta_resource'

module Contract
  class LocalpoolThirdPartyResource < LocalpoolResource

    model LocalpoolThirdParty

    has_one :register_meta, Register::MetaResource

  end
end
