require_relative 'number'
module Buzzn
  module Math
    class Power < Number
    end
    Number.create(Power, :watt, 'W')
  end
end
