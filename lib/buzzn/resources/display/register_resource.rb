module Display
  class RegisterResource < Buzzn::Resource::Entity

    include Import.reader['service.current_power',
                          'service.charts']

    model Register::Base

    attributes  :direction,
                :name,
                :label

    def type
      case object
      when Register::Real
        'register_real'
      when Register::Virtual
        'register_virtual'
      else
        raise "unknown group type: #{object.class}"
      end
    end
    
    # API methods for the endpoints

    def ticker
      current_power.for_register(self)
    end

    def charts(duration:, timestamp: nil)
      @charts.for_register(self, Buzzn::Interval.create(duration, timestamp))
    end
  end
end
