module Register
  class Real < Base

    belongs_to :meter, class_name: Meter::Real, foreign_key: :meter_id

    def obis
      raise 'not implemented'
    end

    before_destroy :change_broker
    after_destroy :validate_meter
    def validate_meter
      unless meter.valid?
        raise Buzzn::NestedValidationError.new(:meter, meter.errors)
      end
    end

    def data_source
      if self.discovergy?
        Buzzn::Discovergy::DataSource::NAME
      elsif self.mysmartgrid?
        Buzzn::MySmartGrid::DataSource::NAME
      else
        Buzzn::StandardProfile::DataSource::NAME
      end
    end

    def change_broker
      if meter.registers.size == 2 && !meter.broker.nil?
        meter.broker.mode = (meter.registers - [self]).first.input? ? :in : :out
      end
    end

  end
end
