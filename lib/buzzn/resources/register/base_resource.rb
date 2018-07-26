require_relative '../reading_resource'

module Register
  class BaseResource < Buzzn::Resource::Entity

    abstract

    model Base

    attributes :label, :direction,
               :last_reading,
               # TODO :share_with_group,
               # TODO :share_publicly,
               :observer_min_threshold,
               :observer_max_threshold,
               :observer_enabled,
               :observer_offline_monitoring,
               :meter_id,
               :updatable, :deletable, :createables

    has_one :meter
    has_one :group
    has_one :market_location
    has_many :readings, ReadingResource
    has_many :contracts

    def last_reading
      reading = object.readings.order('date').last
      reading ? reading.corrected_value.value : 0
    end

    # derive the direction for the label
    def direction
      object.consumption? ? 'in' : 'out'
    end

    def label
      object.meta.attributes['label']
    end

    [:observer_enabled, :observer_min_threshold, :observer_max_threshold, :observer_offline_monitoring].each do |method|
      define_method(method) do
        object.meta.send(method)
      end
    end

  end
end
