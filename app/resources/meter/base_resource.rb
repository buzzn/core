module Meter
  class BaseResource < Buzzn::EntityResource

    abstract

    model Base
    
    attributes  :manufacturer_name,
                :manufacturer_product_name,
                :manufacturer_product_serialnumber

    attributes :updatable, :deletable

  end

  # TODO get rid of the need of having a Serializer class
  class BaseSerializer < BaseResource
    def self.new(*args)
      super
    end
  end
end
