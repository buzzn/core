module Register
  class BaseResource < Buzzn::EntityResource

    abstract

    model Base

    attributes  :direction,
                :name

    # TODO needed ? API methods for the endpoints

    collections :scores

    def comments
      Comment.where(
           commentable_type: Register::Base,
           commentable_id: object.id
      ).readable_by(@current_user)
    end
  end

  class CollectionResource < BaseResource

    attributes :last_reading

    def last_reading
      reading = Reading.by_register_id(object.id).sort('timestamp': -1).first
      reading ? reading.energy_milliwatt_hour : 0 
    end
  end

  class SingleResource < BaseResource

    attributes :pre_decimal,
               :decimal,
               :converter_constant,
               :low_power

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

    # TODO needed ?
    has_one  :address
    has_one  :meter

  end
end
