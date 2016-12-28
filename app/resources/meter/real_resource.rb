module Meter
  class RealResource < BaseResource

    attributes  :smart,
                :online

    has_many :registers

  end
end
