module Meter
  class BaseResource < Buzzn::Resource::Entity

    abstract

    model Base

    attributes :product_serialnumber,
               :sequence_number

    attributes :updatable, :deletable

    has_many :registers

  end
end
