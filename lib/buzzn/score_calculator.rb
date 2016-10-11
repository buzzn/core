module Buzzn

  class ScoreCalculator

    def initialize(group, containing_timestamp)
      @group                = group
      @containing_timestamp = containing_timestamp
      @containing           = Time.at(containing_timestamp).in_time_zone
      @now                  = Time.now.in_time_zone
    end

    def calculate_autarchy_scores
      sum_variation   = 0
      own_consumption = 0
      foreign_consumption = 0
      each do |_in, _out|
        if _in[:power_milliwatt] > _out[:power_milliwatt]
          foreign_consumption += (_in[:power_milliwatt] - _out[:power_milliwatt])
          own_consumption += _out[:power_milliwatt]
        else
          own_consumption += _in[:power_milliwatt]
        end
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
      create_autarchy_score(day_interval, autarchy)

      monthly_score = 0.0
      yearly_score = 0.0
      count_monthly = 0
      count_yearly = 0
      all_scores = @group.scores.autarchies.dayly
      all_scores.each do |score|
        if in_month?(score)
          monthly_score += score.value
          count_monthly += 1
        end
        if in_year?(score)
          yearly_score += score.value
          count_yearly += 1
        end
      end
      count_monthly = 1 if count_monthly == 0
      count_yearly = 1 if count_yearly == 0

      create_autarchy_score(month_interval, monthly_score / count_monthly)
      create_autarchy_score(year_interval, yearly_score / count_yearly)
    end

    def calculate_fitting_scores
      sum_variation = 0
      sumin         = sum_in.to_f
      sumout        = sum_out.to_f
      each do |_in, _out|
        power_in  = _in[:power_milliwatt] / sumin
        power_out = _out[:power_milliwatt] / sumout
        sum_variation += (power_in - power_out) ** 2
      end
      fitting = Math.sqrt(sum_variation)
      if data_size == 0
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
      create_fitting_score(day_interval, score_value)

      monthly_score = 0.0
      yearly_score = 0.0
      count_monthly = 0
      count_yearly = 0
      all_scores = @group.scores.fittings.dayly
      all_scores.each do |score|
        if in_month?(score)
          monthly_score += score.value
          count_monthly += 1
        end
        if in_year?(score)
          yearly_score += score.value
          count_yearly += 1
        end
      end
      count_monthly = 1 if count_monthly == 0
      count_yearly = 1 if count_yearly == 0

      create_fitting_score(month_interval, monthly_score / count_monthly)
      create_fitting_score(year_interval, yearly_score / count_yearly)
    end

    def calculate_closeness_scores
      if day_interval[1] <= @now && day_interval[2] >= @now
        closeness = @group.calculate_current_closeness
      else
        closeness = 0
      end
      create_closeness_score(day_interval, closeness)

      monthly_score = 0.0
      yearly_score = 0.0
      count_monthly = 0
      count_yearly = 0
      all_scores = @group.scores.closenesses.dayly
      all_scores.each do |score|
        if in_month?(score)
          monthly_score += score.value
          count_monthly += 1
        end
        if in_year?(score)
          yearly_score += score.value
          count_yearly += 1
        end
      end
      count_monthly = 1 if count_monthly == 0
      count_yearly = 1 if count_yearly == 0

      create_closeness_score(month_interval, monthly_score / count_monthly)
      create_closeness_score(year_interval, yearly_score / count_yearly)
    end

    def calculate_sufficiency_scores
      count_sn_in_group = @group.energy_consumers.size
      if count_sn_in_group != 0
        sufficiency = @group.extrapolate_kwh_pa(sum_in/4000000.0, 'day', @containing_timestamp) / count_sn_in_group
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
      create_sufficiency_score(day_interval, score_value)

      monthly_score = 0.0
      yearly_score = 0.0
      count_monthly = 0
      count_yearly = 0
      all_scores = @group.scores.sufficiencies.dayly
      all_scores.each do |score|
        if in_month?(score)
          monthly_score += score.value
          count_monthly += 1
        end
        if in_year?(score)
          yearly_score += score.value
          count_yearly += 1
        end
      end
      count_monthly = 1 if count_monthly == 0
      count_yearly = 1 if count_yearly == 0

      create_sufficiency_score(month_interval, monthly_score / count_monthly)
      create_sufficiency_score(year_interval, yearly_score / count_yearly)
    end
    
    def calculate_all_scores
      calculate_autarchy_scores
      calculate_fitting_scores
      calculate_closeness_scores
      calculate_sufficiency_scores
    end

    private

    def in_year?(score)
      score.interval_beginning >= @containing.beginning_of_year && score.interval_end <= @containing.end_of_year
    end

    def in_month?(score)
      score.interval_beginning >= @containing.beginning_of_month && score.interval_end <= @containing.end_of_month
    end

    def retrieve_date(metering_points)
      metering_points_hash = Aggregate.sort_metering_points(metering_points)
      aggregator = Aggregate.new(metering_points_hash)
      aggregator.past(timestamp: @containing,
                      resolution: 'day_to_minutes')
    end

    def data_in
      @data_in ||= retrieve_date(@group.in_metering_points)
    end

    def data_out
      @data_out ||= retrieve_date(@group.out_metering_points)
    end

    def data_size
      @size ||= [data_in.size, data_out.size].min
    end

    def each(&block)
      i             = 0
      datain        = data_in
      dataout       = data_out
      last          = data_size
      while i < last do
        block.call(datain[i], dataout[i])
        i += 1
      end
    end

    def sum_in
      sum_up unless @sum_in
      @sum_in
    end

    def sum_out
      sum_up unless @sum_out
      @sum_out
    end

    def sum_up
      @sum_in = 0
      @sum_out = 0
      each do |_in, _out|
        @sum_in += _in[:power_milliwatt]
        @sum_out += _out[:power_milliwatt]
      end
      if @sum_in == 0
        @sum_in = 1
      end
      if @sum_out == 0
        @sum_out = 1
      end
    end

    def interval(resolution)
      @group.get_score_interval(resolution, @containing_timestamp)
    end

    def day_interval
      @day_interval ||= interval('day')
    end

    def month_interval
      @month_interval ||= interval('month')
    end

    def year_interval
      @year_interval ||= interval('year')
    end

    def create_score(mode, interval_information, value)
      Score.create(mode: mode, interval: interval_information[0], interval_beginning: interval_information[1], interval_end: interval_information[2], value: value, scoreable_type: Group.to_s, scoreable_id: @group.id)
    end

    def create_autarchy_score(interval_information, value)
      create_score('autarchy', interval_information, value)
    end

    def create_fitting_score(interval_information, value)
      create_score('fitting', interval_information, value)
    end

    def create_closeness_score(interval_information, value)
      create_score('closeness', interval_information, value)
    end

    def create_sufficiency_score(interval_information, value)
      create_score('sufficiency', interval_information, value)
    end
  end
end
