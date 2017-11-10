require_relative '../reading_resource'

module Register
  class BaseResource < Buzzn::Resource::Entity

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
               :observer_offline_monitoring,
               :updatable, :deletable, :createables

    has_one :group
    has_many! :readings, ReadingResource

    def last_reading
      reading = object.readings.order('date').last
      reading ? reading.corrected_value.value : 0
    end
  end
end
