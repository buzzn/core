module WithDateRange

  def date_range=(new_range)
    self.begin_date = new_range.first
    self.end_date   = new_range.last
  end

  def date_range
    begin_date...end_date
  end

end
