module Contract
  class LocalpoolPowerTakerResource < BaseResource

    model LocalpoolPowerTaker

    has_one :register
  end
end
