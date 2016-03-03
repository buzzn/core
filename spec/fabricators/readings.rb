Fabricator :reading do
  metering_point_id { Fabricate(:metering_point_with_manager).id }
  timestamp { Time.at(sequence(:watt_hour, 1451602802))  }
  watt_hour { sequence(:watt_hour, 271400000) }
  power     { sequence(:power, 108560) }
end
