module Meter
  class BaseResource < JSONAPI::Resource
    abstract
    
    attributes  :manufacturer_name,
                :manufacturer_product_name,
                :manufacturer_product_serialnumber

  end
end
