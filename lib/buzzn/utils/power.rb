require_relative 'number'
module Buzzn
  module Utils
    class Power < Number
    end
    Number.create(Power, :watt, 'W')
  end
end
