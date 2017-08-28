require_relative 'number'
module Buzzn
  module Math
    class Energy < Number
    end
    Number.create(Energy, :watt_hour, 'Wh')
  end
end
