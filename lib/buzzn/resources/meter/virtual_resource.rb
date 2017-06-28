module Meter
  class VirtualResource < BaseResource

    model Virtual

    has_one :register
  end
end
