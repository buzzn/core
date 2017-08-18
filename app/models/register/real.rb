module Register
  class Real < Base

    belongs_to :meter, class_name: Meter::Real, foreign_key: :meter_id

    def obis
      raise 'not implemented'
    end

    before_destroy :update_broker
    after_destroy :validate_meter
    def validate_meter
      unless meter.valid?
        raise Buzzn::NestedValidationError.new(:meter, meter.errors)
      end
    end

    def data_source
      if self.brokers.detect { |b| b.is_a? Broker::Discovergy }
        Buzzn::Discovergy::DataSource::NAME
      elsif self.brokers.detect { |b| b.is_a? Broker::MySmartGrid }
        Buzzn::MySmartGrid::DataSource::NAME
      else
        Buzzn::StandardProfile::DataSource::NAME
      end
    end

    # TODO untested code
    def update_broker
      if meter.registers.size == 2 && !meter.broker.nil?
        register = (meter.registers - [self]).first
        if register.input?
          meter.broker.update(mode: :in)
        elsif register.output?
          meter.broker.update(mode: :out)
        else
          raise 'unknown direction'
        end
      end
    end

    # tested but unused
    def store_reading_at(time, reason)
      if time.is_a?(Time) && time.beginning_of_day == time
        timestamp = time.to_i
        reading = Reading.new(register_id: self.id,
                              timestamp: timestamp,
                              power_milliwatt: nil,
                              reason: reason,
                              source: Reading::BUZZN_SYSTEMS,
                              quality: Reading::READ_OUT,
                              state: 'Z86',
                              meter_serialnumber: self.meter.product_serialnumber)
        reading.save # updates errors as reading must be invalid now
        invalid = reading.errors.messages.keys.include? :timestamp
        if invalid
          reading.errors.each {|key, value| reading.errors.delete(key) unless key == :timestamp }
          raise Mongoid::Errors::Validations.new(reading)
        end
        data = charts.for_register(self, Buzzn::Interval.second(time))
        if data.nil?
          raise StandardError.new('cannot retrieve reading for register ' + self.id + ' at given time')
        end
        value = case attributes['direction']
                when IN
                  data.in
                when OUT
                  data.out
                else
                  raise "unknown direction #{direction}"
                end.first.value
        reading.energy_milliwatt_hour = value
        reading.save!
      else
        raise ArgumentError.new('need a Time object at beginning of day')
      end
    end
  end
end
