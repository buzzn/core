module Register
  class BaseResource < Buzzn::Resource::Entity

    include Import.reader['service.current_power',
                          'service.charts']

    abstract

    model Base

    attributes :direction,
               :name,
               :pre_decimal_position,
               :post_decimal_position,
               :low_load_ability,
               :label,
               :last_reading,
               :observer_min_threshold,
               :observer_max_threshold,
               :observer_enabled,
               :observer_offline_monitoring

    has_one :group

    # API methods for the endpoints

    def readings
      all(permissions.readings, Reading.by_register_id(object.id))
    end

    def ticker
      current_power.for_register(self)
    end

    def charts(duration:, timestamp: nil)
      @charts.for_register(self, Buzzn::Interval.create(duration, timestamp))
    end

    # attribute implementations

    def last_reading
      reading = Reading.by_register_id(object.id).sort('timestamp': -1).first
      reading ? reading.energy_milliwatt_hour : 0 
    end
  end
end
