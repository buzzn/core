require_relative '../math/energy'
require_relative '../math/power'
require_relative '../math/cubic_meter'

Buzzn::Math::Number::UNITS.each do |unit, _|
  define_method "#{unit}" do |val|
    Buzzn::Math::Number.send unit, val
  end
end
