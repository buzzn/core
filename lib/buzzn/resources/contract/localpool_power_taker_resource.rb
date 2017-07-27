module Contract
  class LocalpoolPowerTakerResource < BaseResource

    model LocalpoolPowerTaker

    attributes  :begin_date
    
    has_one :register
  end
end
