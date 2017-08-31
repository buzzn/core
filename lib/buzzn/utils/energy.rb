require_relative 'number'
module Buzzn
  module Utils
    class Energy < Number
    end
    Number.create(Energy, :watt_hour, 'Wh')
  end
end
