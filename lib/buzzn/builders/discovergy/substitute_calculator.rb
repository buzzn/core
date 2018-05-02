require_relative '../discovergy'

class Builders::Discovergy::SubstituteCalculator

  attr_reader :time, :missing_registers, :substitute

  def initialize(builder)
    @builder = builder
    @to_value = to_value
    @substitute = 0
    @time = 0
    @missing_registers = []
  end

  def process(values, register)
    if values
      value = @to_value.call(values, register)
      @substitute = add(@substitute, value, register)
      @time = [values['time'], @time].max
    else
      @missing_registers << register if register.label.consumption?
    end
  end

  def virtual_value
    (@substitute / @missing_registers.size).to_i if @missing_registers.size > 0
  end

  def value(register)
    value = if register.label.production?
              -@substitute.to_i
            elsif register.label.consumption?
              @substitute.to_i
            else
              raise 'BUG: can handle only production and consuption subsitute registers'
            end
    [0, value].max
  end

  private

  def add(substitute, value, register)
    if register.label.consumption? || register.grid_feeding?
      substitute - value
    elsif register.label.production? || register.grid_consumption?
      substitute + value
    else
      raise "can not handle #{register.class}"
    end
  end

  def unit
    @builder.unit
  end

  def to_value
    case unit
    when :Wh
      @builder.method(:to_watt_hour)
    when :W
      @builder.method(:to_watt)
    else
      raise "unknown unit: #{unit}"
    end
  end

end
