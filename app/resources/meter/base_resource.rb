module Meter
  class BaseResource < Buzzn::Resource::Entity

    abstract

    model Base

    attributes  :manufacturer_name,
                :manufacturer_product_name,
                :manufacturer_product_serialnumber,
                :metering_type,
                :meter_size,
                :ownership,
                :direction_label,
                :build_year


    attributes :updatable, :deletable

    def direction_label; object.direction; end
  end
end
