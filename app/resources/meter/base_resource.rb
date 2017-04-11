module Meter
  class BaseResource < Buzzn::EntityResource

    abstract

    model Base
    
    attributes  :manufacturer_name,
                :manufacturer_product_name,
                :manufacturer_product_serialnumber

    attributes :updatable, :deletable

  end
end
