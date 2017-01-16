module Meter
  class RealResource < BaseResource
    model_name 'Meter::Real'

    attributes  :smart,
                :online

    has_many :registers

  end
end
