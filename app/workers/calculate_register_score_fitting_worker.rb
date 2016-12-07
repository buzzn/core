class CalculateRegisterScoreFittingWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :dead => false

  def perform(register_id, resolution_format, containing_timestamp)
    if resolution_format == 'day'
      @register = Register::Base.find(register_id)
      if @register.group
        chart_data = @register.group.chart(resolution_format, containing_timestamp)
        data_in = @register.chart_data(resolution_format, containing_timestamp)
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
        interval_information = @register.group.set_score_interval(resolution_format, containing_timestamp/1000)
        if i == 0
          fitting = -1
        end
        if fitting < 0
          score_value = 0
        elsif fitting < 0.005
          score_value = 5
        elsif fitting < 0.01
          score_value = 4
        elsif fitting < 0.03
          score_value = 3
        elsif fitting < 0.2
          score_value = 2
        elsif fitting >= 0.2
          score_value = 1
        end
        Score.create(mode: 'fitting', interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: score_value, scoreable_type: 'Register', scoreable_id: @register.id)

        monthly_score = 0
        yearly_score = 0
        count_monthly_fittings = 0
        count_yearly_fittings = 0
        all_scores = @register.scores.fittings.dayly
        all_scores.each do |score|
          if score.interval_beginning >= Time.current.beginning_of_month && score.interval_end <= Time.current.end_of_month
            monthly_score += score.value
            count_monthly_fittings += 1
          end
          if score.interval_beginning >= Time.current.beginning_of_year && score.interval_end <= Time.current.end_of_year
            yearly_score += score.value
            count_yearly_fittings += 1
          end
        end
        interval_information_month = @register.group.set_score_interval('month', containing_timestamp/1000)
        Score.create(mode: 'fitting', interval: interval_information_month[0], interval_beginning: interval_information_month[1], interval_end: interval_information_month[2], value: monthly_score*1.0/count_monthly_fittings, scoreable_type: 'Register', scoreable_id: @register.id)

        interval_information_year = @register.group.set_score_interval('year', containing_timestamp/1000)
        Score.create(mode: 'fitting', interval: interval_information_year[0], interval_beginning: interval_information_year[1], interval_end: interval_information_year[2], value: yearly_score*1.0/count_yearly_fittings, scoreable_type: 'Register', scoreable_id: @register.id)
      end
    elsif resolution_format == 'month'
      puts 'month?'
    elsif resolution_format == 'year'
      puts 'year?'
    end
  end
end