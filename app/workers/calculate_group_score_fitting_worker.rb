class CalculateGroupScoreFittingWorker
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
    sum_in = 0
    sum_out = 0
    while i < data_in.count do
      if i >= data_out.count
        break
      end
      sum_in += data_in[i][1]
      sum_out += data_out[i][1]
      i+=1
    end
    i = 0
    sum_variation = 0
    if sum_in == 0
      sum_in = 1
    end
    if sum_out == 0
      sum_out = 1
    end
    while i < data_in.count do
      if i >= data_out.count
        break
      end
      power_in = data_in[i][1] / (sum_in*1.0)
      power_out = data_out[i][1] / (sum_out*1.0)
      sum_variation += (power_in - power_out)**2
      i+=1
    end
    fitting = Math.sqrt(sum_variation)

    if fitting < 0.005
      return 5
    elsif fitting < 0.01
      return 4
    elsif fitting < 0.03
      return 3
    elsif fitting < 0.2
      return 2
    elsif fitting >= 0.2
      return 1
    else
      return 0
    end
  end
end