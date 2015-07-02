class CalculateGroupScoreSufficiencyWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :dead => false

  def perform(group_id, resolution_format, containing_timestamp)
    if resolution_format == 'day'
      @group = Group.find(group_id)
      count_sn_in_group = 0
      @group.metering_points.each do |metering_point|
        count_sn_in_group += metering_point.users.count if metering_point.input?
        #TODO: enable virtual metering_points
      end
      #result_in = @group.convert_to_array_build_timestamp(Reading.aggregate(resolution_format, @group.metering_points.where(mode: "in").collect(&:id), containing_timestamp), resolution_format, containing_timestamp).flatten
      chart_data = @group.chart(resolution_format, containing_timestamp)
      result_in = chart_data[0][:data]
      if result_in.empty?
        watt_hour = 0
      else
        watt_hour = result_in[0][1]
      end
      if count_sn_in_group != 0
        sufficiency = @group.extrapolate_kwh_pa(watt_hour, resolution_format, containing_timestamp)/count_sn_in_group
      else
        sufficiency = 0
      end
      interval_information = @group.set_score_interval(resolution_format, containing_timestamp/1000)
      if sufficiency <= 0
        score_value = 0
      elsif sufficiency < 500
        score_value = 5
      elsif sufficiency < 900
        score_value = 4
      elsif sufficiency < 1500
        score_value = 3
      elsif sufficiency < 2300
        score_value = 2
      elsif sufficiency >= 2300
        score_value = 1
      end
      Score.create(mode: 'sufficiency', interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: score_value, scoreable_type: 'Group', scoreable_id: group_id)

      monthly_score = 0
      yearly_score = 0
      count_monthly_sufficiencies = 0
      count_yearly_sufficiencies = 0
      all_scores = @group.scores.sufficiencies.dayly
      all_scores.each do |score|
        if score.interval_beginning >= Time.now.beginning_of_month && score.interval_end <= Time.now.end_of_month
          monthly_score += score.value
          count_monthly_sufficiencies += 1
        end
        if score.interval_beginning >= Time.now.beginning_of_year && score.interval_end <= Time.now.end_of_year
          yearly_score += score.value
          count_yearly_sufficiencies += 1
        end
      end
      interval_information_month = @group.set_score_interval('month', containing_timestamp/1000)
      Score.create(mode: 'sufficiency', interval: interval_information_month[0], interval_beginning: interval_information_month[1], interval_end: interval_information_month[2], value: monthly_score*1.0/count_monthly_sufficiencies, scoreable_type: 'Group', scoreable_id: group_id)

      interval_information_year = @group.set_score_interval('year', containing_timestamp/1000)
      Score.create(mode: 'sufficiency', interval: interval_information_year[0], interval_beginning: interval_information_year[1], interval_end: interval_information_year[2], value: yearly_score*1.0/count_yearly_sufficiencies, scoreable_type: 'Group', scoreable_id: group_id)

    elsif resolution_format == 'month'
      puts 'month?'
    elsif resolution_format == 'year'
      puts 'year?'
    end
  end


end