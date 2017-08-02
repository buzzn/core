module Meter
  class BaseResource < Buzzn::Resource::Entity

    abstract

    model Base

    attributes :product_name,
               :product_serialnumber

    attributes :updatable, :deletable

  end
end

