require_relative 'chart'

class Operations::RegisterChart < Operations::Chart

  def call(input, register)
    Success(charts.for_register(register, interval(input)))
  end

end
