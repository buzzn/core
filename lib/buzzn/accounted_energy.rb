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
    CONSUMPTION_LSN_FULL_EEG = "consumption_lsn_full_eeg"
    CONSUMPTION_LSN_REDUCED_EEG = "consumption_lsn_reduced_eeg"
    CONSUMPTION_THIRD_PARTY = "consumption_third_party"

    SINGLE_LABELS = [DEMARCATION_PV,
                     DEMARCATION_CHP,
                     GRID_CONSUMPTION,
                     GRID_FEEDING,
                     GRID_CONSUMPTION_CORRECTED,
                     GRID_FEEDING_CORRECTED].freeze

    MULTI_LABELS = [PRODUCTION_PV,
                    PRODUCTION_CHP,
                    OTHER,
                    CONSUMPTION_LSN_FULL_EEG,
                    CONSUMPTION_LSN_REDUCED_EEG,
                    CONSUMPTION_THIRD_PARTY].freeze

    LABELS = (SINGLE_LABELS + MULTI_LABELS).freeze

    def initialize(value, first_reading, last_reading, last_reading_original,
                   device_change=false, device_change_reading_1=nil,
                   device_change_reading_2=nil)
      raise "not a #{Buzzn::Utils::Energy}: #{value.inspect}" unless value.is_a? Buzzn::Utils::Energy
      @value = value
      @first_reading = first_reading
      @last_reading = last_reading
      @last_reading_original = last_reading_original
      @device_change_reading_1 = device_change_reading_1
      @device_change_reading_2 = device_change_reading_2
      @device_change = device_change
    end
  end

  def ==(o)
    binding.pry
  end
  def eql?(o)
    binding.pry
  end
end
