#
# WARNING: these constants are currently only used in Reading::Continuous and are *different* from the ones
# used in Reading::Single. It's unclear if we'll keep around Reading::Continuous, so I didn't DRY it up, yet.
#
module ReadingEnums

  extend ActiveSupport::Concern

  # reason constants
  DEVICE_SETUP            = 'device_setup'
  DEVICE_CHANGE_1         = 'device_change_1'
  DEVICE_CHANGE_2         = 'device_change_2'
  DEVICE_REMOVAL          = 'device_removal'
  REGULAR_READING         = 'regular_reading'         # "Turnusablesung"
  MIDWAY_READING          = 'midway_reading'          # "Zwischenablesung"
  CONTRACT_CHANGE         = 'contract_change'
  DEVICE_PARAMETER_CHANGE = 'device_parameter_change'
  BALANCING_ZONE_CHANGE   = 'balancing_zone_change'
  OTHER                   = 'other'                   # also used four source

  # quality constants
  UNUSABLE                   = 'unusable'
  SUBSTITUTE_VALUE           = 'substitute_value'
  ENERGY_QUANTITY_SUMMARIZED = 'energy_quantity_summarized'
  FORECAST_VALUE             = 'forecast_value'
  READ_OUT                   = 'read_out'                   # abgelesen
  PROPOSED_VALUE             = 'proposed_value'

  # source constants
  BUZZN               = 'buzzn_systems'
  CUSTOMER_LSG        = 'customer_lsg'        # lsg = localpool strom geber
  LSN                 = 'lsn'                 # lsn = localpool strom nehmer
  VNB                 = 'vnb'                 # vnb = verteilnetzbetreiber
  THIRD_PARTY_MSB_MDL = 'third_party_msb_mdl' # msb = messstellenbetreiber, mdl = messdienstleister
  USER_INPUT          = 'user_input'
  SLP                 = 'slp'
  SEP_PV              = 'sep_pv'
  SEP_BHKW            = 'sep_bhkw'

  class_methods do

    def reasons
      [DEVICE_SETUP, DEVICE_CHANGE_1, DEVICE_CHANGE_2, DEVICE_REMOVAL, REGULAR_READING,
        MIDWAY_READING, CONTRACT_CHANGE, DEVICE_PARAMETER_CHANGE, BALANCING_ZONE_CHANGE, OTHER]
    end

    def qualities
      [UNUSABLE, SUBSTITUTE_VALUE, ENERGY_QUANTITY_SUMMARIZED, FORECAST_VALUE, READ_OUT,
        PROPOSED_VALUE]
    end

    def sources
      [BUZZN, CUSTOMER_LSG, LSN, VNB, THIRD_PARTY_MSB_MDL, OTHER, USER_INPUT, SLP, SEP_PV, SEP_BHKW]
    end

  end

end
