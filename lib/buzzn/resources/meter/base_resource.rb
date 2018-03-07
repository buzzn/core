module Meter
  class BaseResource < Buzzn::Resource::Entity

    abstract

    model Base

    attributes :product_serialnumber,
               :sequence_number,
               :datasource
    attributes :updatable, :deletable

    has_many :registers

  end
end
