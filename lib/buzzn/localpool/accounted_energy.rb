module Buzzn::Localpool
  class AccountedEnergy
    attr_reader :value, :first_reading, :last_reading, :device_change_reading_1, :device_change_reading_2, :device_change

    def initialize(value, first_reading, last_reading, device_change=false, device_change_reading_1=nil, device_change_reading_2=nil)
      @value = value
      @first_reading = first_reading
      @last_reading = last_reading
      @device_change_reading_1 = device_change_reading_1
      @device_change_reading_2 = device_change_reading_2
      @device_change = device_change
    end
  end
end