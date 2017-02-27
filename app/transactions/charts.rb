class Buzzn::Transaction

  class GroupCharts
    include Import['service.charts']

    def call(group, interval)
       Dry::Monads.Right(charts.for_group(group.object, interval))
    end
  end

  class RegisterCharts
    include Import['service.charts']

    def call(register, interval)
      Dry::Monads.Right(charts.for_register(register.object, interval))
    end
  end

  define do |t|

    t.register_step(:interval) do |input|
      Dry::Monads.Right(Buzzn::Interval.create(input[:duration], input[:timestamp]))
    end

    t.register_validation(:charts_schema) do
      required(:duration).value(included_in?: ['year', 'month', 'day', 'hour'])
      optional(:timestamp).filled(:time?)
    end


    t.register_step(:group_charts, GroupCharts.new)

    t.register_step(:register_charts, RegisterCharts.new)

    t.define(:group_charts) do
      validate :charts_schema
      step :interval
      step :group_charts
    end

    t.define(:register_charts) do
      validate :charts_schema
      step :interval
      step :register_charts
    end
  end
end
