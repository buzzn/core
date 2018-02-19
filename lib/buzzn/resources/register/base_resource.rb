require_relative '../reading_resource'

module Register
  class BaseResource < Buzzn::Resource::Entity

    abstract

    model Base

    attributes :label,
               :last_reading,
               :observer_min_threshold,
               :observer_max_threshold,
               :observer_enabled,
               :observer_offline_monitoring,
               :meter_id,
               :kind,
               :updatable, :deletable, :createables

    has_one :meter
    has_one :group
    has_one :market_location
    has_many! :readings, ReadingResource
    has_many :contracts

    def last_reading
      reading = object.readings.order('date').last
      reading ? reading.corrected_value.value : 0
    end

    def kind
      if object.label.production?
        :production
      elsif object.label.consumption?
        :consumption
      else
        :system
      end
    end

  end
end
