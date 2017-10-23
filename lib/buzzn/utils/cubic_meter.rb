require_relative 'number'
module Buzzn
  module Utils
    class CubicMeter < Number
    end
    Number.create(CubicMeter, :cubic_meter, 'm³')
  end
end
