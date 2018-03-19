require_relative 'localpool'

module Contract
  class LocalpoolPowerTaker < Localpool

    belongs_to :register, class_name: 'Register::Input'

  end
end
