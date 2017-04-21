module Meter
  class BaseResource < Buzzn::EntityResource

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

    def self.new(instance, options = {})
      if @abstract
        to_resource(options[:current_user], instance)
      else
        super
      end
    end
  end
end
