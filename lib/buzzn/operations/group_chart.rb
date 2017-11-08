require_relative 'chart'

class Operations::GroupChart < Operations::Chart

  def call(input, group)
    Right(charts.for_group(group, interval(input)))
  end
end
