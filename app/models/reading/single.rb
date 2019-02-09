# coding: utf-8
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
    scope :with_reason, ->(*reasons) { where(reason: reasons.flatten) }
    scope :without_reason, ->(*reasons) { where('reason NOT IN (?)', reasons.flatten) }
    scope :before, ->(date) { where('date < ?', date)}
    scope :after, ->(date) { where('date > ?', date)}
    scope :installed,     -> { with_reason(reasons[:device_setup], reasons[:device_change_1], reasons[:contract_change]) }
    scope :decomissioned, -> { with_reason(reasons[:device_removal], reasons[:device_change_2]) }

    def previous
      Reading::Single.where(:register => self.register).before(date).order(:date).last
    end

    def following
      Reading::Single.where(:register => self.register).after(date).order(:date).first
    end

    def corrected_value
      Buzzn::Utils::Number.send(unit, value)
    end

    def corrected_value=(val)
      self.unit = val.unit
      self.value = val.value
    end

    # persisted readings are referenced in billings and must not be changed.
    # but we allow the deletion unless there is a foreignkey reference on it
    def readonly?
      !(new_record? || !changed?)
    end

  end
end
