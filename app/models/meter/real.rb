require_relative 'base'

module Meter
  class Real < Base

    has_many :registers, class_name: 'Register::Real', foreign_key: :meter_id

    enum manufacturer_name: [:easy_meter, :other].each_with_object({}).each {|k, map| map[k] = k.to_s }

    enum direction_number: {
           one_way_meter: 'ERZ',
           two_way_meter: 'ZRZ',
         }

    enum edifact_voltage_level: {
           low_level:     'E06',
           mid_level:     'E05',
           high_level:    'E04',
           highest_level: 'E03',
         }

    enum edifact_cycle_interval: %i(monthly quarterly half_yearly yearly).each_with_object({}).each { |item, map| map[item] = item.to_s.upcase }

    enum edifact_metering_type: {
           analog_household_meter:  'AHZ',
           analog_ac_meter:         'WSZ', # Wechselstromzähler
           load_meter:              'LAZ', # Lastgangzähler
           maximum_meter:           'MAZ',
           digital_household_meter: 'EHZ',
           individual_adjustment:   'IVA',
         }

    enum edifact_meter_size: {
           edl40: 'Z01',
           edl21: 'Z02',
           other_ehz: 'Z03',
         }

    enum edifact_tariff: {
           single_tariff: 'ETZ',
           dual_tariff:   'ZTZ',
           multi_tariff:  'NTZ',
         }

    enum edifact_data_logging: {
           analog:     'Z04',
           electronic: 'Z05',
         }

    enum edifact_measurement_method: {
           remote: 'AMR',
           manual: 'MMR',
         }

    enum edifact_mounting_method: {
           plug_technique:       'BKE',
           three_point_mounting: 'DPA',
           cap_rail:             'HS' # Hutschiene
         }

    enum ownership: %i(buzzn foreign_ownership customer leased bought).each_with_object({}).each { |item, map| map[item] = item.to_s.upcase }

    before_destroy do
      # we can't use registers.delete_all here because ActiveRecord translates this into a wrong SQL query.
      Register::Real.where(meter_id: self.id).delete_all
    end

  end
end
