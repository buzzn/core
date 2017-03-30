module Buzzn
  class AccountedEnergy
    attr_reader :value, :first_reading, :last_reading, :last_reading_original, :device_change_reading_1, :device_change_reading_2, :device_change
    attr_accessor :label

    #label constants
    DEMARCATION_PV = 'demarcation_pv'
    DEMARCATION_CHP = 'demarcation_chp'
    PRODUCTION_PV = 'production_pv'
    PRODUCTION_CHP = 'production_chp'
    GRID_CONSUMPTION = 'grid_consumption'
    GRID_FEEDING = 'grid_feeding'
    GRID_CONSUMPTION_CORRECTED = 'grid_consumption_corrected'
    GRID_FEEDING_CORRECTED = 'grid_feeding_corrected'
    OTHER = 'other'
    CONSUMPTION_LSN = "consumption_lsn"
    CONSUMPTION_THIRD_PARTY = "consumption_third_party"

    class << self
      def labels
        @label ||= [DEMARCATION_PV, DEMARCATION_CHP, PRODUCTION_PV, PRODUCTION_CHP, GRID_CONSUMPTION, GRID_FEEDING,
                    GRID_CONSUMPTION_CORRECTED, GRID_FEEDING_CORRECTED, OTHER, CONSUMPTION_LSN, CONSUMPTION_THIRD_PARTY]
      end
    end

    def initialize(value, first_reading, last_reading, last_reading_original, device_change=false, device_change_reading_1=nil, device_change_reading_2=nil)
      unless value >= 0
        raise ArgumentError.new("AccountedEnergy value must be greater than or equal to 0.")
      end
      @value = value
      @first_reading = first_reading
      @last_reading = last_reading
      @last_reading_original = last_reading_original
      @device_change_reading_1 = device_change_reading_1
      @device_change_reading_2 = device_change_reading_2
      @device_change = device_change
    end
  end
end