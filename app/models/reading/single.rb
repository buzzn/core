# frozen-string-literal: true
module Reading
  class Single < ActiveRecord::Base

    self.table_name = :readings

    enum reason: {
       device_setup:            'IOM',  # "installation of meter"
       device_change_1:         'COM1', # "change of meter 1"
       device_change_2:         'COM2', # "change of meter 2"
       device_removal:          'ROM',  # "removal of meter"
       regular_reading:         'PMR',  # ?
       midway_reading:          'COT',  # "change of terms"
       contract_change:         'COS',  # "change of service"
       device_parameter_change: 'CMP',  # "changed meter parameters"
       balancing_zone_change:   'COB',  # "change of balancing zone"
     }

    enum quality: {
      unusable:                   '20',
      substitute_value:           '67',
      energy_quantity_summarized: '79',
      forecast_value:             '187',
      read_out:                   '220',
      proposed_value:             '201'
    }

    enum source: {
      smart:  'SM',
      manual: 'MAN'
    }

    enum status: {
      z83: 'Z83',
      z84: 'Z84',
      z86: 'Z86'
    }

    enum read_by: {
      buzzn:                        'BN',
      power_taker:                  'SN', # Stromnehmer
      power_giver:                  'SG', # Stromgeber
      distribution_system_operator: 'VNB' # Verteilnetzbetreiber
    }

    enum unit: {
      watt_hour:   'Wh',
      watt:        'W',
      cubic_meter: 'm³'
    }

    belongs_to :register, class_name: 'Register::Base'

    scope :in_year, ->(year) { where('date >= ? AND date < ?', Date.new(year), Date.new(year + 1)) }
    scope :between, ->(begin_date, end_date) { where('date >= ? AND date < ?', begin_date, end_date) }
    scope :with_reason, ->(*reasons) { where(reason: reasons) }
    scope :without_reason, ->(*reasons) { where('reason NOT IN (?)', reasons) }

    validate :validate_invariants

    def validate_invariants
      if manual? && watt_hour?
        # TODO value_has_to_grow
      end
    end

    # WARNING: as of now, our readings don't always grow over time. Reason:
    # beekeeper had no notion of metering locations, and thus couldn't model it's register changes.
    # Thus all imported readings are stored on the current (and only) register of a metering location, even when
    # the register was swapped at some point. And the readings of a new register typically start much lower.
    #
    # Btw. design-wise, this check should be in the transaction object or at least the market location model.
    # A register model should not load it's adjacent models.
    def value_has_to_grow
      readings = register.readings.manual.order(:date)
      reading_before = readings.where('date < ?', date).last
      reading_after = readings.where('date > ?', date).first
      if !reading_before.nil? && reading_before.value > value
        self.errors.add(:value, "is lower than the last one: #{reading_before.value}")
      end
      if !reading_after.nil? && reading_after.value < value
        self.errors.add(:value, "is greater than the next one: #{reading_after.value}")
      end
    end

    def corrected_value
      Buzzn::Utils::Number.send(unit, value)
    end

    def corrected_value=(val)
      self.unit = val.unit
      self.value = val.value
    end

  end
end
