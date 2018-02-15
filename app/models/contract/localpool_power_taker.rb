require_relative 'localpool'

module Contract
  class LocalpoolPowerTaker < Localpool

    belongs_to :register, class_name: 'Register::Input'

    def begin_reading
      market_location.register.readings.find_by(date: begin_date)
    end

    def end_reading
      market_location.register.readings.find_by(date: end_date)
    end

  end
end
