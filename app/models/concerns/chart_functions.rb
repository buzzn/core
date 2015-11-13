module ChartFunctions
  extend ActiveSupport::Concern

  def chart_comments(resolution, containing_timestamp)
    time = Time.at(containing_timestamp.to_i/1000).in_time_zone
    if resolution == 'hour_to_minutes'
      start_time = time.beginning_of_hour
      end_time = time.end_of_hour
      resolutions = ['hour_to_minutes', 'hour_to_seconds', 'day_to_minutes', 'day_to_hours']
    elsif resolution == 'day_to_hours' || resolution == 'day_to_minutes'
      start_time = time.beginning_of_day
      end_time = time.end_of_day
      resolutions = ['hour_to_minutes', 'hour_to_seconds', 'day_to_minutes', 'day_to_hours']
    elsif resolution == 'month_to_days'
      start_time = time.beginning_of_month
      end_time = time.end_of_month
      resolutions = ['month_to_days', 'year_to_months']
    end
    return Comment.where(commentable_type: self.class, commentable_id: self.id).where('chart_resolution IN (?)', resolutions).where("chart_timestamp > ?", start_time).where("chart_timestamp < ?", end_time).order('chart_timestamp ASC')
  end
end
