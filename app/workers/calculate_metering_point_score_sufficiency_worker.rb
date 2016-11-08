class CalculateMeteringPointScoreSufficiencyWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :dead => false

  def perform(metering_point_id, resolution_format, containing_timestamp)
    if resolution_format == 'day'
      @metering_point = MeteringPoint.find(metering_point_id)
      if @metering_point.group
        count_sn_in_metering_point = @metering_point.users.count
        result_in = @metering_point.chart_data(resolution_format, containing_timestamp)
        if result_in.empty?
          watt_hour = 0
        else
          watt_hour = result_in[0][1]
        end
        if count_sn_in_metering_point != 0
          sufficiency = @metering_point.group.extrapolate_kwh_pa(watt_hour, resolution_format, containing_timestamp)/count_sn_in_metering_point
        else
          sufficiency = 0
        end
        interval_information = @metering_point.group.set_score_interval(resolution_format, containing_timestamp/1000)
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
        Score.create(mode: 'sufficiency', interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: score_value, scoreable_type: 'MeteringPoint', scoreable_id: @metering_point.id)

        monthly_score = 0
        yearly_score = 0
        count_monthly_sufficiencies = 0
        count_yearly_sufficiencies = 0
        all_scores = @metering_point.scores.sufficiencies.dayly
        all_scores.each do |score|
          if score.interval_beginning >= Time.current.beginning_of_month && score.interval_end <= Time.current.end_of_month
            monthly_score += score.value
            count_monthly_sufficiencies += 1
          end
          if score.interval_beginning >= Time.current.beginning_of_year && score.interval_end <= Time.current.end_of_year
            yearly_score += score.value
            count_yearly_sufficiencies += 1
          end
        end
        interval_information_month = @metering_point.group.set_score_interval('month', containing_timestamp/1000)
        Score.create(mode: 'sufficiency', interval: interval_information_month[0], interval_beginning: interval_information_month[1], interval_end: interval_information_month[2], value: monthly_score*1.0/count_monthly_sufficiencies, scoreable_type: 'MeteringPoint', scoreable_id: @metering_point.id)

        interval_information_year = @metering_point.group.set_score_interval('year', containing_timestamp/1000)
        Score.create(mode: 'sufficiency', interval: interval_information_year[0], interval_beginning: interval_information_year[1], interval_end: interval_information_year[2], value: yearly_score*1.0/count_yearly_sufficiencies, scoreable_type: 'MeteringPoint', scoreable_id: @metering_point.id)

      end
    elsif resolution_format == 'month'
      puts 'month?'
    elsif resolution_format == 'year'
      puts 'year?'
    end
  end
end