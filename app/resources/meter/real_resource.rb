module Meter
  class RealResource < BaseResource
    model_name 'Meter::Real'

    attributes  :smart

    has_many :registers

  end
end
