module ChartFunctions
  extend ActiveSupport::Concern

  def chart_comments(resolution, containing_timestamp)
    time = Time.at(containing_timestamp.to_i/1000).in_time_zone
    if resolution == 'hour_to_minutes'
      start_time = time.beginning_of_hour
      end_time = time.end_of_hour
      resolutions = ['hour_to_minutes', 'hour_to_seconds', 'day_to_minutes']
    elsif resolution == 'day_to_hours' || resolution == 'day_to_minutes'
      start_time = time.beginning_of_day
      end_time = time.end_of_day
      resolutions = ['hour_to_minutes', 'hour_to_seconds', 'day_to_minutes']
    elsif resolution == 'month_to_days'
      start_time = time.beginning_of_month
      end_time = time.end_of_month
      resolutions = ['month_to_days']
    elsif resolution == 'year_to_months'
      start_time = time.beginning_of_year
      end_time = time.end_of_year
      resolutions = ['year_to_months']
    end
    type = self.class.to_s.include?('Register') ? 'Register::Base' : self.class
    return Comment.where(commentable_type: type, commentable_id: self.id).where('chart_resolution IN (?)', resolutions).where("chart_timestamp >= ?", start_time).where("chart_timestamp < ?", end_time).order('chart_timestamp ASC')
  end

  def get_cache_duration(resolution)
    if resolution == "hour_to_minutes"
      return 1.minute
    elsif resolution == "day_to_minutes"
      return 3.minutes
    elsif resolution == "month_to_days"
      return 2.hours
    elsif resolution == "year_to_months"
      return 1.day
    end
  end

  def get_cache_interval(resolution, containing_timestamp)
    time = Time.at(containing_timestamp.to_i/1000).in_time_zone
    if resolution == "hour_to_minutes"
      start_time = time.beginning_of_hour
      end_time = time.end_of_hour
    elsif resolution == "day_to_minutes"
      start_time = time.beginning_of_day
      end_time = time.end_of_day
    elsif resolution == "month_to_days"
      start_time = time.beginning_of_month
      end_time = time.end_of_month
    elsif resolution == "year_to_months"
      start_time = time.beginning_of_year
      end_time = time.end_of_year
    end
    return start_time.to_i.to_s + "_" + end_time.to_i.to_s
  end


end
