ReadingsCheck = Struct.new(:contract) do

  delegate :contract_number, :contract_number_addition, :begin_date, :end_date, to: :contract

  def inspect
    return if ignore_contract?
    unless missing_readings.empty?
      puts "\n- #{nr} (#{begin_date} - #{end_date || 'today'})"
      puts missing_readings.join("\n")
    else
      # intentionally no output
    end
  end

  private

  # These contracts have virtual meters which we haven't imported yet, so there are no readings.
  def ignore_contract?
    contract.register.name == "FAKE-FOR-IMPORT"
  end

  def missing_readings
    dates = []
    dates << contract.begin_date unless has_begin_date_reading?
    _missing_yearly_readings = missing_yearly_readings
    dates << missing_yearly_readings unless _missing_yearly_readings.empty?
    if contract.end_date
      dates << contract.end_date unless has_end_date_reading?
    end
    dates.flatten
  end

  def has_begin_date_reading?
    actual_readings_dates.include?(contract.begin_date)
  end

  def has_end_date_reading?
    actual_readings_dates.include?(contract.end_date)
  end

  def missing_yearly_readings
    missing_years = billing_years.reject do |year|
      last_day_in_year       = Date.new(year, 12, 31)
      first_day_in_next_year = Date.new(year + 1, 1, 1)
      actual_readings_dates.include?(last_day_in_year) || actual_readings_dates.include?(first_day_in_next_year)
    end
    missing_years.map { |year| Date.new(year, 12, 31) }
  end

  LATEST_BILLING_YEAR = 2016

  def billing_years
    range_start = (begin_date.year)
    range_end = end_date ? (end_date.year - 1) : LATEST_BILLING_YEAR
    range_start..range_end
  end

  def actual_readings_dates
    @actual_readings ||= contract.register.readings.pluck(:date)
  end

  def closest_reading_dates(date)
    lower_boundary = (date - 1.month)
    upper_boundary = (date + 1.month)
    actual_readings_dates.select do |actual_date|
      (lower_boundary..upper_boundary).include?(actual_date)
    end
  end

  def nr
    "#{contract_number}/#{contract_number_addition}"
  end
end

all_contracts = Contract::LocalpoolPowerTaker
  .joins(:localpool)
  .where("groups.name !~ 'Localpool|Testgruppe'")
  .order(:contract_number, :contract_number_addition).each do |contract|
end

last_name = nil
all_contracts.each do |c|
  puts "\n\n# #{c.localpool.name}" if (last_name != c.localpool.name)
  last_name = c.localpool.name
  r = ReadingsCheck.new(c).inspect
  puts r if r
end
