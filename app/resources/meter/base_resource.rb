module Meter
  class BaseSerializer < ActiveModel::Serializer
    
    attributes  :manufacturer_name,
                :manufacturer_product_name,
                :manufacturer_product_serialnumber

  end
  class GuardedBaseSerializer

    def self.new(resource, options = {})
      case resource
      when Real
        GuardedRealSerializer.new(resource, options)
      when Virtual
        GuardedVirtualSerializer.new(resource, options)
      else
        raise "can not handle type: #{resource.class}"
      end
    end
  end
end
