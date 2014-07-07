


date      = Date.new(2014,1,1)
minute    = date.beginning_of_day
watt_hour = 0
fake_readings  = []
while minute < date.end_of_day
  minute    += 1.minute
  watt_hour += 35
  if (date.middle_of_day..(date.middle_of_day+30.minutes)).cover?(minute)
    watt_hour += 1000
  end
  fake_readings << [minute, watt_hour]
end

puts fake_readings