require_relative '../utils/energy'
require_relative '../utils/power'
require_relative '../utils/cubic_meter'

Buzzn::Utils::Number::UNITS.each do |unit, _|
  define_method "#{unit}" do |val|
    Buzzn::Utils::Number.send unit, val
  end
end
