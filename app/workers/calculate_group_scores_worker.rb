class CalculateGroupScoresWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :dead => false

  def perform(group_id, resolution_format, containing_timestamp)
    if resolution_format == 'day'
      @group = Group.find(group_id)
      resolution = 'day_to_minutes'

      metering_points_hash_in = Aggregate.sort_metering_points(@group.in_metering_points)
      aggregator_in = Aggregate.new(metering_points_hash_in)
      data_in = aggregator_in.past(timestamp: Time.at(containing_timestamp), resolution: 'day_to_minutes')
      metering_points_hash_out = Aggregate.sort_metering_points(@group.out_metering_points)
      aggregator_out = Aggregate.new(metering_points_hash_out)
      data_out = aggregator_out.past(timestamp: Time.at(containing_timestamp), resolution: 'day_to_minutes')

      #autarchy
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
      autarchy = 0
      if own_consumption + foreign_consumption != 0
        autarchy_percentage = own_consumption * 1.0 / (own_consumption + foreign_consumption)
        if autarchy_percentage <= 0.1
          autarchy = 0
        elsif autarchy_percentage <= 0.3
          autarchy = 1
        elsif autarchy_percentage <= 0.5
          autarchy = 2
        elsif autarchy_percentage <= 0.7
          autarchy = 3
        elsif autarchy_percentage <= 0.9
          autarchy = 4
        elsif autarchy_percentage <= 1.0
          autarchy = 5
        end
      end
      interval_information = @group.set_score_interval(resolution_format, containing_timestamp)

      Score.create(mode: 'autarchy', interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: autarchy, scoreable_type: 'Group', scoreable_id: group_id)

      monthly_score = 0
      yearly_score = 0
      count_monthly_autarchies = 0
      count_yearly_autarchies = 0
      all_scores = @group.scores.autarchies.dayly
      all_scores.each do |score|
        if score.interval_beginning >= Time.at(containing_timestamp).in_time_zone.beginning_of_month && score.interval_end <= Time.now.end_of_month
          monthly_score += score.value
          count_monthly_autarchies += 1
        end
        if score.interval_beginning >= Time.at(containing_timestamp).in_time_zone.beginning_of_year && score.interval_end <= Time.now.end_of_year
          yearly_score += score.value
          count_yearly_autarchies += 1
        end
      end
      interval_information_month = @group.set_score_interval('month', containing_timestamp)
      Score.create(mode: 'autarchy', interval: interval_information_month[0], interval_beginning: interval_information_month[1], interval_end: interval_information_month[2], value: monthly_score*1.0/count_monthly_autarchies, scoreable_type: 'Group', scoreable_id: group_id)

      interval_information_year = @group.set_score_interval('year', containing_timestamp)
      Score.create(mode: 'autarchy', interval: interval_information_year[0], interval_beginning: interval_information_year[1], interval_end: interval_information_year[2], value: yearly_score*1.0/count_yearly_autarchies, scoreable_type: 'Group', scoreable_id: group_id)






      #fitting
      i = 0
      sum_in = 0
      sum_out = 0
      while i < data_in.count do
        if i >= data_out.count
          break
        end
        sum_in += data_in[i][:power_milliwatt]
        sum_out += data_out[i][:power_milliwatt]
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
        power_in = data_in[i][:power_milliwatt] / (sum_in*1.0)
        power_out = data_out[i][:power_milliwatt] / (sum_out*1.0)
        sum_variation += (power_in - power_out)**2
        i+=1
      end
      fitting = Math.sqrt(sum_variation)
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
      Score.create(mode: 'fitting', interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: score_value, scoreable_type: 'Group', scoreable_id: group_id)

      monthly_score = 0
      yearly_score = 0
      count_monthly_fittings = 0
      count_yearly_fittings = 0
      all_scores = @group.scores.fittings.dayly
      all_scores.each do |score|
        if score.interval_beginning >= Time.now.beginning_of_month && score.interval_end <= Time.now.end_of_month
          monthly_score += score.value
          count_monthly_fittings += 1
        end
        if score.interval_beginning >= Time.now.beginning_of_year && score.interval_end <= Time.now.end_of_year
          yearly_score += score.value
          count_yearly_fittings += 1
        end
      end
      Score.create(mode: 'fitting', interval: interval_information_month[0], interval_beginning: interval_information_month[1], interval_end: interval_information_month[2], value: monthly_score*1.0/count_monthly_fittings, scoreable_type: 'Group', scoreable_id: group_id)
      Score.create(mode: 'fitting', interval: interval_information_year[0], interval_beginning: interval_information_year[1], interval_end: interval_information_year[2], value: yearly_score*1.0/count_yearly_fittings, scoreable_type: 'Group', scoreable_id: group_id)




      #closeness
      closeness = @group.calculate_current_closeness
      Score.create(mode: 'closeness', interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: closeness, scoreable_type: 'Group', scoreable_id: group_id)

      monthly_score = 0
      yearly_score = 0
      count_monthly_closenesses = 0
      count_yearly_closenesses = 0
      all_scores = @group.scores.closenesses.dayly
      all_scores.each do |score|
        if score.interval_beginning >= Time.now.beginning_of_month && score.interval_end <= Time.now.end_of_month
          monthly_score += score.value
          count_monthly_closenesses += 1
        end
        if score.interval_beginning >= Time.now.beginning_of_year && score.interval_end <= Time.now.end_of_year
          yearly_score += score.value
          count_yearly_closenesses += 1
        end
      end
      Score.create(mode: 'closeness', interval: interval_information_month[0], interval_beginning: interval_information_month[1], interval_end: interval_information_month[2], value: monthly_score*1.0/count_monthly_closenesses, scoreable_type: 'Group', scoreable_id: group_id)
      Score.create(mode: 'closeness', interval: interval_information_year[0], interval_beginning: interval_information_year[1], interval_end: interval_information_year[2], value: yearly_score*1.0/count_yearly_closenesses, scoreable_type: 'Group', scoreable_id: group_id)





      #sufficiency
      count_sn_in_group = @group.energy_consumers.size
      if count_sn_in_group != 0
        sufficiency = @group.extrapolate_kwh_pa(sum_in/4000000.0, resolution_format, containing_timestamp)/count_sn_in_group
      else
        sufficiency = 0
      end
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
      Score.create(mode: 'sufficiency', interval: interval_information_month[0], interval_beginning: interval_information_month[1], interval_end: interval_information_month[2], value: monthly_score*1.0/count_monthly_sufficiencies, scoreable_type: 'Group', scoreable_id: group_id)
      Score.create(mode: 'sufficiency', interval: interval_information_year[0], interval_beginning: interval_information_year[1], interval_end: interval_information_year[2], value: yearly_score*1.0/count_yearly_sufficiencies, scoreable_type: 'Group', scoreable_id: group_id)
    elsif resolution_format == 'month'
      puts 'month?'
    elsif resolution_format == 'year'
      puts 'year?'
    end
  end
end