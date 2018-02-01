Contract::LocalpoolPowerTaker.order(:begin_date).each do |contract|
  next if !contract.status.ended?
  next if contract.begin_date.year < 2017
  if contract.begin_reading.nil? || contract.end_reading.nil?
    puts "#{contract.id} has no begin reading" if contract.begin_reading.nil?
    puts "#{contract.id} has no end reading" if contract.end_reading.nil?
  end
end
