class CalculateGroupScoreAutarchyWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :dead => false

  def perform(group_id, resolution_format, containing_timestamp)
    if resolution_format == 'day'
      @group = Group.find(group_id)
      resolution_format = 'day_to_minutes'
      chart_data = @group.chart(resolution_format, containing_timestamp)
      data_in = chart_data[0][:data]
      data_out = chart_data[1][:data]
      i = 0
      sum_variation = 0
      autarchy = 0
      while i < data_in.count && i < data_out.count do
        if data_in[i][1] > data_out[i][1]
          sum_variation += (data_out[i][1])/(data_in[i][1] * 1.0)
        else
          sum_variation += 1
        end
        i+=1
      end
      if i != 0
        autarchy = sum_variation*1.0 / i
      else
        autarchy = -1
      end
      interval_information = @group.set_score_interval(resolution_format, containing_timestamp/1000)

      Score.create(mode: 'autarchy', interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: autarchy, scoreable_type: 'Group', scoreable_id: group_id)

      monthly_score = 0
      yearly_score = 0
      count_monthly_autarchies = 0
      count_yearly_autarchies = 0
      all_scores = @group.scores.autarchies.dayly
      all_scores.each do |score|
        if score.interval_beginning >= Time.now.beginning_of_month && score.interval_end <= Time.now.end_of_month
          monthly_score += score.value
          count_monthly_autarchies += 1
        end
        if score.interval_beginning >= Time.now.beginning_of_year && score.interval_end <= Time.now.end_of_year
          yearly_score += score.value
          count_yearly_autarchies += 1
        end
      end
      interval_information_month = @group.set_score_interval('month', containing_timestamp/1000)
      Score.create(mode: 'autarchy', interval: interval_information_month[0], interval_beginning: interval_information_month[1], interval_end: interval_information_month[2], value: monthly_score*1.0/count_monthly_autarchies, scoreable_type: 'Group', scoreable_id: group_id)

      interval_information_year = @group.set_score_interval('year', containing_timestamp/1000)
      Score.create(mode: 'autarchy', interval: interval_information_year[0], interval_beginning: interval_information_year[1], interval_end: interval_information_year[2], value: yearly_score*1.0/count_yearly_autarchies, scoreable_type: 'Group', scoreable_id: group_id)
    elsif resolution_format == 'month'
      puts 'month?'
    elsif resolution_format == 'year'
      puts 'year?'
    end
  end
end