class CalculateGroupScoreAutarchyWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :dead => false

  def perform(group_id, resolution_format, containing_timestamp)
    @group = Group.find(group_id)
    if resolution_format == :year
      resolution_format = :year_to_minutes
    elsif resolution_format == :month
      resolution_format = :month_to_minutes
    elsif resolution_format == :day
      resolution_format = :day_to_minutes
    end
    chart_data = @group.chart(resolution_format, containing_timestamp)
    data_in = chart_data[0][:data]
    data_out = chart_data[1][:data]
    i = 0
    sum_variation = 0
    while i < data_in.count do
      if i >= data_out.count
        break
      end
      if data_in[i][1] > data_out[i][1]
        sum_variation += (data_in[i][1] - data_out[i][1])/(data_in[i][1] * 1.0)
      end
      i+=1
    end

    if i != 0
      autarchy = sum_variation / i
    else
      return 5
    end

    if autarchy < 0.1
      return 5
    elsif autarchy < 0.2
      return 4
    elsif autarchy < 0.5
      return 3
    elsif autarchy < 0.75
      return 2
    elsif autarchy >= 0.75
      return 1
    else
      return 0
    end
  end
end