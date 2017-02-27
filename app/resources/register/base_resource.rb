module Register
  class BaseResource < Buzzn::EntityResource

    abstract

    model Base

    attributes  :direction,
                :name,
                :pre_decimal,
                :decimal,
                :converter_constant,
                :low_power,
                :last_reading

    #has_one :address
    has_one :group

    # API methods for the endpoints

    def readings
      Reading.by_register_id(object.id).collect do |r|
        ReadingResource.new(r, current_user: current_user)
      end
    end

    # attribute implementations

    def pre_decimal
      object.digits_before_comma
    end

    def decimal
      object.decimal_digits
    end

    def converter_constant
      main = object.meter.main_equipment
      main ? main.converter_constant : nil
    end

    def low_power
      object.low_load_ability
    end

    def last_reading
      reading = Reading.by_register_id(object.id).sort('timestamp': -1).first
      reading ? reading.energy_milliwatt_hour : 0 
    end
  end
end
