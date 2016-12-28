module Register
  class Real < Register::Base

    belongs_to :meter, class_name: Meter::Real, foreign_key: :meter_id

    def obis
      raise 'not implemented'
    end

    after_destroy :validate_meter
    def validate_meter
      unless meter.valid?
        raise Buzzn::NestedValidationError.new(:meter, meter.errors)
      end
    end
  end
end
