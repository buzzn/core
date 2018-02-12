require_relative 'base'

module Register
  class Real < Base

    include Import.active_record['services.charts']

    belongs_to :meter, class_name: 'Meter::Real', foreign_key: :meter_id

    delegate :address, to: :meter, allow_nil: true

    def obis
      raise 'not implemented'
    end

    def data_source
      if self.broker.is_a? Broker::Discovergy
        Services::Datasource::Discovergy::Implementation::NAME
      else
        Services::Datasource::StandardProfile::Implementation::NAME
      end
    end

    # tested but unused
    def store_reading_at(time, reason)
      if time.is_a?(Time) && time.beginning_of_day == time
        timestamp = time.to_i
        reading = Reading::Continuous.new(register_id: self.id,
                              timestamp: timestamp,
                              power_milliwatt: nil,
                              reason: reason,
                              source: Reading::Continuous::BUZZN,
                              quality: Reading::Continuous::READ_OUT,
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
                when Base.directions[:input]
                  data.in
                when Base.directions[:output]
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
