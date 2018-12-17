module LastDate

  # In order to be continuous, an end_date is the same as the start_date of the following entity.
  # This is technically correct but unexpected by robots. That's why we have the last_date, which will show
  # the human-expected last date of the entity.
  def last_date
    end_date && (end_date - 1.day)
  end

end
