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

    def data_source
      if self.discovergy?
        Buzzn::Discovergy::DataSource::NAME
      elsif self.mysmartgrid?
        Buzzn::MySmartGrid::DataSource::NAME
      else
        Buzzn::StandardProfile::DataSource::NAME
      end
    end

  end
end
