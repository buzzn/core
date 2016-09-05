class CalculateGroupScoreAutarchyWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :dead => false

  def perform(group_id, resolution_format, containing_timestamp)
    if resolution_format == 'day'
      @group = Group.find(group_id)
      resolution_format = 'day_to_minutes'

      metering_points_hash_in = Aggregate.sort_metering_points(@group.in_metering_points)
      aggregator_in = Aggregate.new(metering_points_hash_in)
      data_in = aggregator_in.past(timestamp: Time.now - 1.day, resolution: 'day_to_minutes')
      metering_points_hash_out = Aggregate.sort_metering_points(@group.out_metering_points)
      aggregator_out = Aggregate.new(metering_points_hash_out)
      data_out = aggregator_out.past(timestamp: Time.now - 1.day, resolution: 'day_to_minutes')

      i = 0
      own_consumption = 0
      foreign_consumption = 0
      while i < data_in.count && i < data_out.count do
        if data_in[i][:power_milliwatt] > data_out[i][:power_milliwatt]
          foreign_consumption += (data_in[i][:power_milliwatt] - data_out[i][:power_milliwatt])
          own_consumption += data_out[i][:power_milliwatt]
        else
          own_consumption += data_in[i][:power_milliwatt]
        end
        i+=1
      end
      if own_consumption + foreign_consumption != 0
        autarchy = own_consumption * 1.0 / (own_consumption + foreign_consumption)
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
        if score.interval_beginning >= Time.at(containing_timestamp.to_i/1000).in_time_zone.beginning_of_month && score.interval_end <= Time.now.end_of_month
          monthly_score += score.value
          count_monthly_autarchies += 1
        end
        if score.interval_beginning >= Time.at(containing_timestamp.to_i/1000).in_time_zone.beginning_of_year && score.interval_end <= Time.now.end_of_year
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