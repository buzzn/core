require_relative 'localpool_resource'
require_relative '../register/meta_resource'

module Contract
  class LocalpoolThirdPartyResource < LocalpoolResource

    model LocalpoolThirdParty

    attributes :share_register_with_group,
               :share_register_publicly

    has_one :register_meta, Register::MetaResource

    def share_register_with_group
      object.register_meta_option.nil? ? false : object.register_meta_option.share_with_group
    end

    def share_register_publicly
      object.register_meta_option.nil? ? false : object.register_meta_option.share_publicly
    end

  end
end
