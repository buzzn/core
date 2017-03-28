module Buzzn
  class AccountedEnergy
    attr_reader :value, :first_reading, :last_reading, :last_reading_original, :device_change_reading_1, :device_change_reading_2, :device_change
    attr_accessor :label

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