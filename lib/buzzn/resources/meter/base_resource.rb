module Meter
  class BaseResource < Buzzn::Resource::Entity

    abstract

    model Base

    attributes :product_name,
               :product_serialnumber,
               :sequence_number

    attributes :updatable, :deletable
  end
end

