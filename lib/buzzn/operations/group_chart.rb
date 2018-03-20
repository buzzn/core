require_relative 'chart'

class Operations::GroupChart < Operations::Chart

  def call(input, group)
    Success(charts.for_group(group, interval(input)))
  end

end
