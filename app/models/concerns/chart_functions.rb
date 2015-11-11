module ChartFunctions
  extend ActiveSupport::Concern

  def chart_comments(resolution, containing_timestamp)
    time = Time.at(containing_timestamp.to_i/1000)
    if resolution == 'hour_to_minutes'
      start_time = time.beginning_of_hour
      end_time = time.end_of_hour
    elsif resolution == 'day_to_hours' || resolution == 'day_to_minutes'
      start_time = time.beginning_of_day
      end_time = time.end_of_day
    elsif resolution == 'month_to_days'
      start_time = time.beginning_of_month
      end_time = time.end_of_month
    end
    return Comment.where(commentable_type: self.class, commentable_id: self.id, chart_resolution: resolution).where("chart_timestamp > ?", start_time).where("chart_timestamp < ?", end_time).order('chart_timestamp ASC')
  end
end
