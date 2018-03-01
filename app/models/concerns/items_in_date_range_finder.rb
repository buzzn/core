module ItemsInDateRangeFinder

  def find_items_in_date_range(item, date_range)
    item
      .where('end_date IS NULL OR end_date > ?', date_range.first) # fetch items running or ended in the period
      .where('begin_date < ?', date_range.last) # don't fetch items starting after the period
      .order(:begin_date) # ensure chronological order to ease testing
  end

end
