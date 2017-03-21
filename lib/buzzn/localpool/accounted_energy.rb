module Buzzn::Localpool
  class AccountedEnergy
    attr_reader :date, :energy_miliwatt_hour, :contains_device_change

    # This class contains the information about the accounted energy
    # input params:
    #   date: the date of the billing cycle's ending (mostly 31st December)
    #   energy_milliwatt_hour: energy measured from the last billing cycle until the end of this billing cycle
    #   contains_device_change: indicates whether in the billing cycle was a device_change ot not
    def initialize(date, energy_miliwatt_hour, contains_device_change=false)
      @date = case date
              when Date
                date
              when Time
                date.to_date
              when String
                date.to_date
              when Fixnum
                (date / 1000.0).to_date
              when Float
                (Time.at(date)).to_date
              else
                raise ArgumentError.new("date not a Date, Time, String, Fixnum or Float: #{date.class}")
              end
      @energy_miliwatt_hour = energy_miliwatt_hour
      @contains_device_change = contains_device_change
    end
  end
end