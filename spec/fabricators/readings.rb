Fabricator :reading do
  timestamp { Time.at(sequence(:watt_hour, 1451602802))  }
  watt_hour { sequence(:watt_hour, 271400000) }
  power     { 900 }
end


Fabricator :reading_with_metering_point, from: :reading do
  metering_point_id { Fabricate(:metering_point).id  }
end

Fabricator :reading_with_metering_point_and_manager, from: :reading do
  metering_point_id { Fabricate(:metering_point_with_manager).id  }
end
