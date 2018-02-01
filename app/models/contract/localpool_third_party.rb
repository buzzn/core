require_relative 'localpool'

module Contract
  class LocalpoolThirdParty < Localpool

    belongs_to :register, class_name: 'Register::Input'

  end
end
