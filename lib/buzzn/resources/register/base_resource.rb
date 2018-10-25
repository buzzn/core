require_relative '../reading_resource'
require_relative 'meta_resource'

module Register
  class BaseResource < Buzzn::Resource::Entity

    abstract

    model Base

    attributes :direction,
               :last_reading,
               :meter_id,
               :updatable, :deletable, :createables

    has_one :meter
    has_one :group

    has_one :register_meta, MetaResource do |object|
      object.meta
    end

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

  end
end
