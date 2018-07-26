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
    elsif register.consumption?
      @missing_registers << register
    end
  end

  def virtual_value
    unless @missing_registers.empty?
      (@substitute / @missing_registers.size).to_i
    end
  end

  def value(register)
    value = if register.production?
              -@substitute.to_i
            elsif register.consumption?
              @substitute.to_i
            else
              raise 'BUG: can handle only production and consuption subsitute registers'
            end
    [0, value].max
  end

  private

  def add(substitute, value, register)
    if register.consumption? || register.meta.grid_feeding?
      substitute - value
    elsif register.production? || register.meta.grid_consumption?
      substitute + value
    else
      raise "can not handle #{register.inspect}"
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
