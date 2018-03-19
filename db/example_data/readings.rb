def all_reading_dates(localpool)
  dates = []
  localpool.market_locations.each do |market_location|
    # add first date to the beginning
    dates << [market_location.register, localpool.start_date, :device_setup]
    # yearly dates
    ((localpool.start_date.year + 1)..Date.today.year).each do |year|
      dates << [market_location.register, Date.new(year, 1, 1), :regular_reading]
    end
    # now add contract end dates
    market_location.contracts.select(&:ended?).each do |contract|
      dates << [market_location.register, contract.end_date, :contract_change]
    end
  end
  dates
    .uniq { |register, date, reason| "#{register.id}-#{date}-#{reason}" } # remove possible duplicates
    .sort_by { |register, date, reason| date } # sort to the created readings increase over time
end

def previous_reading_value(register, date)
  previous_reading = register.readings.where('date < ?', date).order(date: :desc).first
  previous_reading&.raw_value || 0
end

def randomized_new_reading(register, date)
  previous_reading = previous_reading_value(register, date)
  new_consumption  = rand(2_000..3_000) * 1_000
  previous_reading + new_consumption
end

all_reading_dates(SampleData.localpools.people_power).each do |register, date, reason|
  begin
    FactoryGirl.create(:reading,
                       date:      date,
                       register:  register,
                       raw_value: randomized_new_reading(register, date),
                       reason:    reason)
  rescue StandardError => e
    if e.message =~ /duplicate key value violates unique constraint/ # ignore the error if we already have the reading
      next
    else
      raise
    end
  end
end
