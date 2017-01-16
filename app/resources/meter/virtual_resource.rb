module Meter
  class VirtualResource < BaseResource
    model_name 'Meter::Virtual'

    has_one :register

  end
end
